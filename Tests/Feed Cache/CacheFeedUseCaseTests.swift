//
//  Created by Daniel Moro on 7.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

class FeedStore {
    var deleteCachedFeedCalloutCount: Int = 0
    var insertCachedFeedCalloutCount: Int = 0

    func deleteCacheFeed() {
        deleteCachedFeedCalloutCount += 1
    }

    func completeDeletion(with _: Error, at _: Int) {}
}

class LocalFeedLoader {
    init(store: FeedStore) {
        self.store = store
    }

    var store: FeedStore

    func save(_: [FeedItem]) {
        store.deleteCacheFeed()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deleteCachedFeedCalloutCount, 0)
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCalloutCount, 1)
    }

//    func test_save_doesNotRequestInsertionIfDeletionFails() {
//        let (sut, store) = makeSUT()
//        let items = [uniqueItem(), uniqueItem()]
//        let expectedError = anyNSError()
//        store.deletionError = expectedError
//
//        let exp = XCTestExpectation(description: "wait for save completion")
//        sut.save(items) { error in
//            XCTAssertEqual(error as NSError?, expectedError)
//            exp.fulfill()
//        }
//
//        wait(for: [exp], timeout: 1)
//
//    }

    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError, at: 0)

        XCTAssertEqual(store.insertCachedFeedCalloutCount, 0)
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
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
