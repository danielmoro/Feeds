//
//  Created by Daniel Moro on 30.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import XCTest

protocol FeedView {
    func display(feed: [FeedImage])
}

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedErrorView {
    func display(error: String?)
}

final class FeedPresenter {
    private let feedView: FeedView
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView

    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        errorView.display(error: nil)
        loadingView.display(isLoading: true)
    }

    func didFinishLoadingFeed(with items: [FeedImage]) {
        feedView.display(feed: items)
        loadingView.display(isLoading: false)
    }
}

class FeedPresentationTests: XCTestCase {
    func test_init_doesNotPressentErrorToAnyView() {
        let (_, view) = makeSUT()
        XCTAssertEqual(view.messages.isEmpty, true)
    }

    func test_didStartLoadingFeed_presentNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.displayError(nil), .displayIsLoading(true)])
    }

    func test_didFinishLoadingFeedWithItems_displaysLoadedFeedAndFinishLoading() {
        let (sut, view) = makeSUT()
        let anyFeed = [uniqueImage(), uniqueImage()]
        sut.didFinishLoadingFeed(with: anyFeed)
        XCTAssertEqual(view.messages, [.displayItems(anyFeed), .displayIsLoading(false)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
        trackMemoryLeaks(view, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        enum Message: Equatable {
            case displayError(String?)
            case displayIsLoading(Bool)
            case displayItems([FeedImage])
        }

        var messages: [Message] = []

        func display(error: String?) {
            messages.append(.displayError(error))
        }

        func display(isLoading: Bool) {
            messages.append(.displayIsLoading(isLoading))
        }

        func display(feed: [FeedImage]) {
            messages.append(.displayItems(feed))
        }
    }
}
