//
//  Created by Daniel Moro on 22.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() throws
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws
    func test_retrieve_deliversFoundValuesOnExistingCache() throws
    func test_retrieve_hasNoSideEffectsOnExistingCache() throws

    func test_insert_deliversNoErrorOnEmptyCache() throws
    func test_insert_deliversNoErrorOnNonEmptyCache() throws
    func test_insert_overridesPreviouslyInsertedCacheValues() throws

    func test_delete_deliversNoErrorOnEmptyCache() throws
    func test_delete_deliversNoErrorOnNonEmptyCache() throws
    func test_delete_hasNoSideEffectsOnEmptyCache() throws
    func test_delete_emptiesPreviouslyInsertedCache() throws

    func test_storeSideEffects_runSerially() throws
}

protocol FailableRetreiveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetreivalError() throws
    func test_retrieve_hasNoSideEffectsOnRetreivalError() throws
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_failsOnInsertionError() throws
    func test_insert_hasNoSideEffectsOnInsertionError() throws
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_failsOnDeletionError() throws
    func test_delete_hasNoSideEffectsOnDeletionError() throws
}

typealias FailableFeedStoreSpecs = FailableRetreiveFeedStoreSpecs &
    FailableInsertFeedStoreSpecs &
    FailableDeleteFeedStoreSpecs
