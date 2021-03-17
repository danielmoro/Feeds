//
//  Created by Daniel Moro on 17.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validate_deletesCacheOnRetreivalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetreival(with: anyNSError(), at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }

    func test_validate_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetreivalWithEmptyCache(at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validate_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        sut.validateCache()
        store.completeRetreival(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp, at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
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
