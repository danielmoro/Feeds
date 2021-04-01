//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit
import XCTest

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }

    @objc
    private func load() {
        refreshControl?.beginRefreshing()
        loader?.load(completion: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedLoad() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.completions.count, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.completions.count, 1)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.completions.count, 2)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.completions.count, 3)
    }

    func test_loadFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true)

        loader.complete(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)

        loader.complete(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    class LoaderSpy: FeedLoader {
        var completions: [(FeedLoader.Result) -> Void] = []

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }

        func complete(at index: Int) {
            completions[index](.success([]))
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
}
