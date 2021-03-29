//
//  Created by Daniel Moro on 29.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
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

//        assertThatRetrieveDeliversFoundValuesOnExistingCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnExistingCache() {}

    func test_insert_deliversNoErrorOnEmptyCache() {}

    func test_insert_deliversNoErrorOnNonEmptyCache() {}

    func test_insert_overridesPreviouslyInsertedCacheValues() {}

    func test_delete_deliversNoErrorOnEmptyCache() {}

    func test_delete_deliversNoErrorOnNonEmptyCache() {}

    func test_delete_hasNoSideEffectsOnEmptyCache() {}

    func test_delete_emptiesPreviouslyInsertedCache() {}

    func test_storeSideEffects_runSerially() {}

    // MARK: - Helpers

    private func makeSUT() -> FeedStore {
        let sut = CoreDataFeedStore()
        trackMemoryLeaks(sut)

        return sut
    }
}
