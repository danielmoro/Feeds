//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import XCTest

class FeedViewController {
    init(loader _: FeedViewControllerTests.LoaderSpy) {}
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadRequestCount, 0)
    }

    // MARK: - Helpers

    class LoaderSpy {
        var loadRequestCount: Int = 0
    }
}
