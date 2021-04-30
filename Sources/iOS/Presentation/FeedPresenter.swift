//
//  Created by Daniel Moro on 12.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView

    var title: String {
        "Feed"
    }

    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }

    func didStartLoadingFeed() {
        loadingView.display(isLoading: true)
    }

    func didFinishLoadingFeed(with items: [FeedImage]) {
        feedView.display(feed: items)
        loadingView.display(isLoading: false)
    }

    func didFinishLoadingFeed(with _: Error) {
        loadingView.display(isLoading: false)
    }
}
