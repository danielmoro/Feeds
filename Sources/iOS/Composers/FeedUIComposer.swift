//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public final class FeedUIComposer {
    private init() {}
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(presenter: feedPresenter, feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presentationAdapter.loadFeed)
        let feedController = FeedViewController(refreshController: refreshController)
        let feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        let loadingView = WeakRefVirtualProxy(refreshController)
        feedPresenter.feedView = feedView
        feedPresenter.loadingView = loadingView

        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

private final class FeedLoaderPresentationAdapter {
    private let presenter: FeedPresenter
    private let feedLoader: FeedLoader

    init(presenter: FeedPresenter, feedLoader: FeedLoader) {
        self.presenter = presenter
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        presenter.didStartLoadingFeed()
        feedLoader.load { [weak presenter] result in
            switch result {
            case let .success(feed):
                presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

final class FeedViewAdapter: FeedView {
    init(controller: FeedViewController, loader: FeedImageLoader) {
        self.controller = controller
        self.loader = loader
    }

    private weak var controller: FeedViewController?
    private var loader: FeedImageLoader

    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            let viewModel = FeedImageViewModel(model: model, loader: loader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
