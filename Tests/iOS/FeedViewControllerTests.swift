//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds_iOS
import FeedsCore
import UIKit
import XCTest

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedLoad() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.completions.count, 0, "Expect no loading request before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.completions.count, 1, "Expect loading reqest once view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.completions.count, 2, "Expect another loading request after user initiated reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            loader.completions.count,
            3,
            "Expect yet another loading request after another user initiated reload"
        )
    }

    func test_loadFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            true,
            "Expect loading indicator to be visible once view is loaded"
        )

        loader.complete(at: 0)
        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            false,
            "Expect loading indicator no to be visible after load is complete"
        )

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            true,
            "Expect loading indicator to be visible user initiated reload"
        )

        loader.complete(at: 1)
        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            false,
            "Expect loading indicator note no to be visible after user initiated load is complete"
        )
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
