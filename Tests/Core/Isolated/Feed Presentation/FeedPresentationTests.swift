//
//  Created by Daniel Moro on 30.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import XCTest

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

    func test_didFinishLoadingFeedWithError_displaysErrorAndFinishLoading() {
        let (sut, view) = makeSUT()
        let error = anyNSError()
        sut.didFinishLoadingFeed(with: error)
        XCTAssertEqual(view.messages, [.displayError(localize("FEED_VIEW_CONNECTION_ERROR")), .displayIsLoading(false)])
    }

    func test_title() {
        let (sut, view) = makeSUT()
        XCTAssertEqual(FeedPresenter.title, localize("FEED_TITLE_VIEW"))
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

extension FeedPresentationTests {
    func localize(
        _ key: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let table = "Feeds"
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
        if localizedString == key {
            XCTFail("Missing localization for \(key)", file: file, line: line)
        }

        return localizedString
    }
}
