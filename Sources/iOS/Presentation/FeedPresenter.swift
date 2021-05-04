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

final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView

    static var title: String {
        let bundle = Bundle(for: FeedPresenter.self)
        return NSLocalizedString("FEED_TITLE_VIEW", tableName: "Feeds", bundle: bundle, comment: "")
    }

    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }

    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.didStartLoadingFeed()
            }
            return
        }

        loadingView.display(isLoading: true)
    }

    func didFinishLoadingFeed(with items: [FeedImage]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.didFinishLoadingFeed(with: items)
            }
            return
        }

        feedView.display(feed: items)
        loadingView.display(isLoading: false)
    }

    func didFinishLoadingFeed(with error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.didFinishLoadingFeed(with: error)
            }
            return
        }

        loadingView.display(isLoading: false)
    }
}
