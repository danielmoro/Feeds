//
//  Created by Daniel Moro on 13.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
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

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetreivalWithEmptyCache(at: 0)
        }
    }

    func test_load_deliversCachedImagesOnNotExpiriedCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let notExpiriedTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetreival(with: feed.local, timestamp: notExpiriedTimestamp, at: 0)
        }
    }

    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetreival(with: feed.local, timestamp: sevenDaysOldTimestamp, at: 0)
        }
    }

    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThansevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetreival(with: feed.local, timestamp: moreThansevenDaysOldTimestamp, at: 0)
        }
    }

    func test_load_hasNoSideEffectsOnRetreivalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetreival(with: anyNSError(), at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetreivalWithEmptyCache(at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        sut.load { _ in }
        store.completeRetreival(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp, at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)

        sut.load { _ in }
        store.completeRetreival(with: feed.local, timestamp: sevenDaysOldTimestamp, at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnMoreThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThansevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

        sut.load { _ in }
        store.completeRetreival(with: feed.local, timestamp: moreThansevenDaysOldTimestamp, at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_doesNotDeliversImagesAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedMessages: [LocalFeedLoader.LoadResult] = []
        sut?.load { receivedMessages.append($0) }

        sut = nil
        store.completeRetreivalWithEmptyCache(at: 0)

        XCTAssertEqual(receivedMessages.count, 0)
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

    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LoadFeedResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var receivedResult: LoadFeedResult?
        let exp = XCTestExpectation(description: "wait for retreival completion")
        sut.load { result in
            receivedResult = result
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)

        switch (expectedResult, receivedResult) {
        case let (.success(expectedImages), .success(receivedImages)):
            XCTAssertEqual(expectedImages, receivedImages, file: file, line: line)
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
}
