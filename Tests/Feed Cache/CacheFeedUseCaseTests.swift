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

    var insertions: [(items: [FeedItem], timestamp: Date)] = []
    var deletionCompletions: [DeletionCompletion] = []

    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCalloutCount += 1
        deletionCompletions.append(completion)
    }

    func insert(items: [FeedItem], timestamp: Date) {
        insertCachedFeedCalloutCount += 1
        insertions.append((items, timestamp))
    }

    func completeDeletion(with error: Error, at index: Int) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccesfully(at index: Int) {
        deletionCompletions[index](nil)
    }

    func completeInsertion(with _: [FeedItem], at _: Int) {}
}

class LocalFeedLoader {
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    var store: FeedStore
    var currentDate: () -> Date

    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.store.insert(items: items, timestamp: self.currentDate())
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
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccesfully(at: 0)

        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timeStamp)
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
