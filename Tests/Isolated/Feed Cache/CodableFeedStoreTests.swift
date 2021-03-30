//
//  CodableFeedStoreTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 20.3.21..
//

import Feeds
import Foundation
import XCTest

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

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnExistingCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnExistingCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnExistingCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnExistingCache(on: sut)
    }

    func test_retrieve_deliversFailureOnRetreivalError() {
        let invalidStoreURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: invalidStoreURL)

        try? "invalid data".write(to: invalidStoreURL, atomically: true, encoding: .utf8)

        assertThatRetrieveDeliversFailureOnRetreivalError(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnRetreivalError() {
        let invalidStoreURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: invalidStoreURL)

        try? "invalid data".write(to: invalidStoreURL, atomically: true, encoding: .utf8)

        assertThatRetrieveTasNoSideEffectsOnRetreivalError(on: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)

        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }

    func test_insert_failsOnInsertionError() {
        let invalidStoreURL = URL(fileURLWithPath: "file://invalid-url")
        let sut = makeSUT(storeURL: invalidStoreURL)

        assertThatInsertFailsOnInsertionError(on: sut)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_delete_failsOnDeletionError() {
        let nonDeletableStoreURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletableStoreURL)

        assertThatDeleteFailsOnDeletionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let nonDeletableStoreURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletableStoreURL)

        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()

        assertThatStoreSideEffectsRunSerially(on: sut)
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
}
