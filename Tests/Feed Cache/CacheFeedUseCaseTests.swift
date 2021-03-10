//
//  Created by Daniel Moro on 7.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

class FeedStore {
    typealias Completion = (Error?) -> Void

    var deletionCompletions: [Completion] = []
    var insertionCompletions: [Completion] = []

    enum ReceivedMessage: Equatable {
        case insert(items: [FeedItem], timestamp: Date)
        case delete
    }

    var receivedMessages: [ReceivedMessage] = []

    func deleteCacheFeed(completion: @escaping Completion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.delete)
    }

    func insert(items: [FeedItem], timestamp: Date, completion: @escaping Completion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items: items, timestamp: timestamp))
    }

    func completeDeletion(with error: Error, at index: Int) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccesfully(at index: Int) {
        deletionCompletions[index](nil)
    }

    func completeInsertion(with _: [FeedItem], at index: Int) {
        insertionCompletions[index](nil)
    }

    func completeInsertion(with error: Error, at index: Int) {
        insertionCompletions[index](error)
    }
}

class LocalFeedLoader {
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    var store: FeedStore
    var currentDate: () -> Date

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.store.insert(items: items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }

        XCTAssertEqual(store.receivedMessages, [.delete])
    }

    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()

        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError, at: 0)

        XCTAssertEqual(store.receivedMessages, [.delete])
    }

    func test_save_requestNewCacheInsertionwithTimestampOnSucessfulDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }
        store.completeDeletionSuccesfully(at: 0)

        XCTAssertEqual(store.receivedMessages, [.delete, .insert(items: items, timestamp: timeStamp)])
    }

    func test_save_failOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError, at: 0)
        }
    }

    func test_save_failOnInsertionError() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccesfully(at: 0)
            store.completeInsertion(with: insertionError, at: 0)
        }
    }

    func test_save_succedsOnSuccessfulInsertion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]

        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccesfully(at: 0)
            store.completeInsertion(with: items, at: 0)
        }
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

    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWithError expectedError: Error?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let items = [uniqueItem(), uniqueItem()]

        let exp = XCTestExpectation(description: "wait for save completion")
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
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
