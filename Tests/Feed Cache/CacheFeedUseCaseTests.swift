//
//  Created by Daniel Moro on 7.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import XCTest

class FeedStore {
    var deleteCachedFeedCalloutCount: Int = 0
}

class LocalFeedLoader {
    init(store: FeedStore) {
        self.store = store
    }

    var store: FeedStore
    
    
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let client = FeedStore()
        _ = LocalFeedLoader(store: client)

        XCTAssertEqual(client.deleteCachedFeedCalloutCount, 0)
    }
}
