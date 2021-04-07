//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContentView = UIImageView()
    public lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        return button
    }()

    public var onRetry: (() -> Void)?

    @objc
    private func reloadButtonTapped() {
        onRetry?()
    }
}

public protocol FeedImageLoadTask {
    func cancel()
}

public protocol FeedImageLoader {
    typealias FeedImageResult = Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (FeedImageResult) -> Void) -> FeedImageLoadTask
}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageLoader?
    private var tableModel: [FeedImage] = []
    private var tasks: [IndexPath: FeedImageLoadTask] = [:]

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
        load()
    }

    @objc
    private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load(completion: { [weak self] result in
            if let newResult = try? result.get() {
                self?.tableModel = newResult
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        })
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedImageCell()
        let feedImage = tableModel[indexPath.row]
        cell.descriptionLabel.text = feedImage.description
        cell.locationLabel.text = feedImage.location
        cell.locationContainer.isHidden = feedImage.location == nil
        cell.imageContentView.image = nil
        cell.reloadButton.isHidden = true
        cell.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: feedImage.url) { result in

                if let data = try? result.get(), let image = UIImage(data: data) {
                    cell.imageContentView.image = image
                } else {
                    cell.reloadButton.isHidden = false
                }

                cell.stopShimmering()
            }
        }

        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url, completion: { _ in })
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cancelTask(forRowAt: indexPath)
        }
    }

    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
