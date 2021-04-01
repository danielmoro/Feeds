//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit
import XCTest

class FeedViewController: UIViewController {
    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loader?.load(completion: { _ in })
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadRequestCount, 0)
    }

    func test_load_loadsFeedOnViewLoad() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadRequestCount, 1)
    }

    // MARK: - Helpers

    class LoaderSpy: FeedLoader {
        var loadRequestCount: Int = 0

        func load(completion _: @escaping (FeedLoader.Result) -> Void) {
            loadRequestCount += 1
        }
    }
}
