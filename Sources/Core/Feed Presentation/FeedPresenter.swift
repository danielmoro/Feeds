//
//  Created by Daniel Moro on 30.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public protocol FeedView {
    func display(feed: [FeedImage])
}

public protocol FeedLoadingView {
    func display(isLoading: Bool)
}

public protocol FeedErrorView {
    func display(error: String?)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView

    public static var title: String {
        let bundle = Bundle(for: FeedPresenter.self)
        return NSLocalizedString("FEED_TITLE_VIEW", tableName: "Feeds", bundle: bundle, comment: "")
    }

    static var errorMessage: String {
        let bundle = Bundle(for: FeedPresenter.self)
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feeds", bundle: bundle, comment: "")
    }

    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingFeed() {
        errorView.display(error: nil)
        loadingView.display(isLoading: true)
    }

    public func didFinishLoadingFeed(with items: [FeedImage]) {
        feedView.display(feed: items)
        loadingView.display(isLoading: false)
    }

    public func didFinishLoadingFeed(with _: Error) {
        errorView.display(error: FeedPresenter.errorMessage)
        loadingView.display(isLoading: false)
    }
}
