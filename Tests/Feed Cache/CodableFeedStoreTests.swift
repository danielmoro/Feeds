//
//  CodableFeedStoreTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 20.3.21..
//

import Feeds
import Foundation
import XCTest

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnExistingCache()
    func test_retrieve_hasNoSideEffectsOnExistingCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()

    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerialy()
}

protocol FailableRetreiveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetreivalError()
    func test_retrieve_hasNoSideEffectsOnRetreivalError()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_failsOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_failsOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStoreSpecs = FailableRetreiveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    private func setupEmptyStoreState() {
        removeCache()
    }

    override func tearDown() {
        super.tearDown()
        undoTestSideEffects()
    }

    private func undoTestSideEffects() {
        removeCache()
    }

    private func removeCache() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toReceive: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toReceiveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnExistingCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert(sut, feed: feed, timestamp: timestamp)

        expect(sut, toReceive: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsOnExistingCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert(sut, feed: feed, timestamp: timestamp)

        expect(sut, toReceiveTwice: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_deliversFailureOnRetreivalError() {
        let invalidStoreURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: invalidStoreURL)

        try? "invalid data".write(to: invalidStoreURL, atomically: true, encoding: .utf8)

        expect(sut, toReceive: .failure(anyNSError()))
    }

    func test_retrieve_hasNoSideEffectsOnRetreivalError() {
        let invalidStoreURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: invalidStoreURL)

        try? "invalid data".write(to: invalidStoreURL, atomically: true, encoding: .utf8)

        expect(sut, toReceiveTwice: .failure(anyNSError()))
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let firstFeed = uniqueImageFeed().local
        let firstTimetamp = Date()
        let insertionError = insert(sut, feed: firstFeed, timestamp: firstTimetamp)
        XCTAssertNil(insertionError)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let firstFeed = uniqueImageFeed().local
        let firstTimetamp = Date()
        insert(sut, feed: firstFeed, timestamp: firstTimetamp)

        let latestFeed = uniqueImageFeed().local
        let latestTimetamp = Date()
        let insertionError = insert(sut, feed: latestFeed, timestamp: latestTimetamp)
        XCTAssertNil(insertionError)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let firstFeed = uniqueImageFeed().local
        let firstTimetamp = Date()
        insert(sut, feed: firstFeed, timestamp: firstTimetamp)

        let latestFeed = uniqueImageFeed().local
        let latestTimetamp = Date()
        insert(sut, feed: latestFeed, timestamp: latestTimetamp)

        expect(sut, toReceive: .found(feed: latestFeed, timestamp: latestTimetamp))
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert(sut, feed: feed, timestamp: timestamp)

        expect(sut, toReceive: .empty)
    }

    func test_insert_failsOnInsertionError() {
        let invalidStoreURL = URL(fileURLWithPath: "file://invalid-url")
        let sut = makeSUT(storeURL: invalidStoreURL)

        let insertionError = insert(sut, feed: uniqueImageFeed().local, timestamp: Date())

        XCTAssertNotNil(insertionError)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(sut)
        XCTAssertNil(deletionError)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        deleteCache(sut)

        expect(sut, toReceive: .empty)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert(sut, feed: uniqueImageFeed().local, timestamp: Date())

        let deletionError = deleteCache(sut)
        XCTAssertNil(deletionError)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert(sut, feed: uniqueImageFeed().local, timestamp: Date())

        deleteCache(sut)

        expect(sut, toReceive: .empty)
    }

    func test_delete_failsOnDeletionError() {
        let nonDeletableStoreURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletableStoreURL)

        let deletionError = deleteCache(sut)
        XCTAssertNotNil(deletionError)
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let nonDeletableStoreURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletableStoreURL)

        deleteCache(sut)

        expect(sut, toReceive: .empty)
    }

    func test_storeSideEffects_runSerialy() {
        let sut = makeSUT()

        var executedOperations: [XCTestExpectation] = []

        let op1 = expectation(description: "Operation 1")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            executedOperations.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheFeed { _ in
            executedOperations.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            executedOperations.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertEqual(executedOperations, [op1, op2, op3])
    }

    // MARK: Helpers

    private func cachesDirectory() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesURL
    }

    private func testSpecificStoreURL() -> URL {
        let storeURL = cachesDirectory().appendingPathComponent("\(type(of: self)).store")
        return storeURL
    }

    private func makeSUT(storeURL: URL? = nil) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackMemoryLeaks(sut)
        return sut
    }

    private func expect(
        _ sut: FeedStore,
        toReceive expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = XCTestExpectation(description: "wait for retreival to complete")

        sut.retreive { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.empty, .empty):
                break
            case (.failure, .failure):
                break
            case let (.found(feed: receivedFeed, timestamp: receivedTimestamp),
                      .found(feed: expectedFeed, timestamp: expectedTimestamp)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected to receive \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func expect(
        _ sut: FeedStore,
        toReceiveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toReceive: expectedResult, file: file, line: line)
        expect(sut, toReceive: expectedResult, file: file, line: line)
    }

    @discardableResult
    private func insert(
        _ sut: FeedStore,
        feed: [LocalFeedImage],
        timestamp: Date
    ) -> Error? {
        var receivedError: Error?
        let exp = XCTestExpectation(description: "wait for insertion to complete")
        sut.insert(feed: feed, timestamp: timestamp) { error in
            receivedError = error
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedError
    }

    @discardableResult
    private func deleteCache(
        _ sut: FeedStore
    ) -> Error? {
        var receivedError: Error?
        let exp = XCTestExpectation(description: "wait for deletion to complete")
        sut.deleteCacheFeed { deletionError in
            receivedError = deletionError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
}
