//
//  Created by Daniel Moro on 30.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import XCTest

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedErrorView {
    func display(error: String?)
}

final class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView

    init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        errorView.display(error: nil)
        loadingView.display(isLoading: true)
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

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView: view, errorView: view)
        trackMemoryLeaks(view, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    private class ViewSpy: FeedErrorView, FeedLoadingView {
        enum Messages: Equatable {
            case displayError(String?)
            case displayIsLoading(Bool)
        }

        var messages: [Messages] = []

        func display(error: String?) {
            messages.append(.displayError(error))
        }

        func display(isLoading: Bool) {
            messages.append(.displayIsLoading(isLoading))
        }
    }
}
