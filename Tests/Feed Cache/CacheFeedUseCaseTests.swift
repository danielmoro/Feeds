//
//  Created by Daniel Moro on 7.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    var deleteCachedFeedCalloutCount: Int = 0
    var insertCachedFeedCalloutCount: Int = 0

    var deletionCompletions: [DeletionCompletion] = []

    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCalloutCount += 1
        deletionCompletions.append(completion)
    }

    func insertCasheFeed() {
        insertCachedFeedCalloutCount += 1
    }

    func completeDeletion(with error: Error, at index: Int) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccesfully(at index: Int) {
        deletionCompletions[index](nil)
    }
}

class LocalFeedLoader {
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    var store: FeedStore
    var currentDate: () -> Date

    func save(_: [FeedItem]) {
        store.deleteCacheFeed { [weak self] error in
            if error == nil {
                self?.store.insertCasheFeed()
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCachedFeedCalloutCount, 0)
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCalloutCount, 1)
    }

    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError, at: 0)

        XCTAssertEqual(store.insertCachedFeedCalloutCount, 0)
    }

    func test_save_requestInsertionOnSucessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccesfully(at: 0)

        XCTAssertEqual(store.insertCachedFeedCalloutCount, 1)
    }

    func test_save_requestNewCacheInsertionwithTimestampOnSucessfulDeletion() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccesfully(at: 0)

        XCTAssertEqual(store.insertCachedFeedCalloutCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        return (sut: sut, store: store)
    }

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }
}
