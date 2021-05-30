//
//  Created by Daniel Moro on 12.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import Foundation

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

protocol FeedErrorView {
    func display(error: String)
}

final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    static var title: String {
        let bundle = Bundle(for: FeedPresenter.self)
        return NSLocalizedString("FEED_TITLE_VIEW", tableName: "Feeds", bundle: bundle, comment: "")
    }

    static var errorMessage: String {
        let bundle = Bundle(for: FeedPresenter.self)
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feeds", bundle: bundle, comment: "")
    }

    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        loadingView.display(isLoading: true)
    }

    func didFinishLoadingFeed(with items: [FeedImage]) {
        feedView.display(feed: items)
        loadingView.display(isLoading: false)
    }

    func didFinishLoadingFeed(with _: Error) {
        errorView.display(error: FeedPresenter.errorMessage)
        loadingView.display(isLoading: false)
    }
}
