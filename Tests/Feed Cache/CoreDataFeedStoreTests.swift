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

    func test_insert_deliversNoErrorOnEmptyCache() throws {}

    func test_insert_deliversNoErrorOnNonEmptyCache() throws {}

    func test_insert_overridesPreviouslyInsertedCacheValues() throws {}

    func test_delete_deliversNoErrorOnEmptyCache() throws {}

    func test_delete_deliversNoErrorOnNonEmptyCache() throws {}

    func test_delete_hasNoSideEffectsOnEmptyCache() throws {}

    func test_delete_emptiesPreviouslyInsertedCache() throws {}

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
