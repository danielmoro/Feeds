//
//  Created by Daniel Moro on 22.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

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

    func test_storeSideEffects_runSerially()
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

typealias FailableFeedStoreSpecs = FailableRetreiveFeedStoreSpecs &
    FailableInsertFeedStoreSpecs &
    FailableDeleteFeedStoreSpecs
