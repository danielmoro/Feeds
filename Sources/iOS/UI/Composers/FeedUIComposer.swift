//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public final class FeedUIComposer {
    private init() {}
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        let decorator = MainQueueDispatchDecorator(decoratee: feedLoader)
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: decorator)
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        let feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        let loadingView = WeakRefVirtualProxy(feedController)
        presentationAdapter.presenter = FeedPresenter(feedView: feedView, loadingView: loadingView)

        return feedController
    }
}

private final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController // swiftlint:disable:this force_cast
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    var presenter: FeedPresenter?
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
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
            FeedImageCellComposer.feedImageCellComposedWith(model: model, loader: loader)
        }
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView {
    func display(_ model: FeedImageModel<T.Image>) {
        object?.display(model)
    }
}

enum FeedImageCellComposer {
    public static func feedImageCellComposedWith(model: FeedImage, loader: FeedImageLoader) -> FeedImageCellController {
        let adapter = FeedImageCellPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, loader: loader)
        let controller = FeedImageCellController(delegate: adapter)
        adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(controller), imageTransformer: UIImage.init)
        return controller
    }
}

final class FeedImageCellPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    init(model: FeedImage, loader: FeedImageLoader) {
        self.model = model
        self.loader = loader
    }

    private var model: FeedImage
    private var task: FeedImageLoadTask?
    private var loader: FeedImageLoader

    var presenter: FeedImagePresenter<View, Image>?

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        task = loader.loadImageData(from: model.url, completion: { [weak self] resut in
            switch resut {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFailLoadingImageData(with: error, for: model)
            }
        })
    }

    func didCancelImageRequest() {
        task?.cancel()
    }
}
