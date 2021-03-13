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

    // MARK: - Helpers

    private class FeedStoreSpy: FeedStore {
        var deletionCompletions: [Completion] = []
        var insertionCompletions: [Completion] = []

        enum ReceivedMessage: Equatable {
            case insert(feed: [LocalFeedImage], timestamp: Date)
            case delete
        }

        var receivedMessages: [ReceivedMessage] = []

        func deleteCacheFeed(completion: @escaping Completion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.delete)
        }

        func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(feed: feed, timestamp: timestamp))
        }

        func completeDeletion(with error: Error, at index: Int) {
            deletionCompletions[index](error)
        }

        func completeDeletionSuccesfully(at index: Int) {
            deletionCompletions[index](nil)
        }

        func completeInsertion(with _: [FeedImage], at index: Int) {
            insertionCompletions[index](nil)
        }

        func completeInsertion(with error: Error, at index: Int) {
            insertionCompletions[index](error)
        }
    }

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
}
