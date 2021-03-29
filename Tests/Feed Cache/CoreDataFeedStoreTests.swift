//
//  Created by Daniel Moro on 29.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnExistingCache() throws {
        let sut = try makeSUT()

        assertThatRetrieveDeliversFoundValuesOnExistingCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnExistingCache() throws {
        let sut = try makeSUT()

        assertThatRetrieveHasNoSideEffectsOnExistingCache(on: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        let sut = try makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_delete_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()

        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() throws {
        let sut = try makeSUT()

        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_storeSideEffects_runSerially() throws {}

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> FeedStore {
        let url = URL(fileURLWithPath: "/dev/null/")
        let sut = try CoreDataFeedStore(url: url)
        trackMemoryLeaks(sut, file: file, line: line)

        return sut
    }
}
