//
//  LoadFeedFromCacheUseCaseTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 13.3.21..
//

import Feeds
import XCTest

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestsCacheRetreivalFromTheStore() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetreivalError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()

        expect(sut, toCompleteWith: .failure(expectedError)) {
            store.completeRetreival(with: expectedError, at: 0)
        }
    }

    func test_load_deliverNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .empty) {
            store.completeRetreivalWithEmptyCache(at: 0)
        }
    }

    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let lessThanSevenDaysOldTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
        expect(sut, toCompleteWith: .found(feed: feed.local, timestamp: lessThanSevenDaysOldTimestamp)) {
            store.completeRetreival(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp, at: 0)
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        return (sut: sut, store: store)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }

    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var receivedResult: LocalFeedLoader.LoadResult?
        let exp = XCTestExpectation(description: "wait for retreival completion")
        sut.load { result in
            receivedResult = result
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)

        switch (expectedResult, receivedResult) {
        case (.empty, .empty):
            XCTAssertTrue(true)
        case let (
            .found(feed: expectedImages, timestamp: expectedTimestamp),
            .found(feed: receivedImages, timestamp: receivedTimestamp)
        ):
            XCTAssertEqual(expectedImages, receivedImages, file: file, line: line)
            XCTAssertEqual(expectedTimestamp, receivedTimestamp)
        case let (.failure(expectedError as NSError), .failure(receivedError as NSError)):
            XCTAssertEqual(expectedError, receivedError, file: file, line: line)
        default:
            XCTFail(
                "expected to receive \(expectedResult), got \(String(describing: receivedResult)) instead",
                file: file,
                line: line
            )
        }
    }

    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }

    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }

    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        let localImageFeed = feed.map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }

        return (feed, localImageFeed)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        addingTimeInterval(seconds)
    }
}
