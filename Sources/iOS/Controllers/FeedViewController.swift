//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public class FeedImageCellController {}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedRefreshController: FeedRefreshViewController?
    private var imageLoader: FeedImageLoader?
    private var tableModel: [FeedImage] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var tasks: [IndexPath: FeedImageLoadTask] = [:]

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageLoader) {
        self.init()
        feedRefreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = feedRefreshController?.view
        feedRefreshController?.onRefresh = { [weak self] result in
            self?.tableModel = result
        }

        tableView.prefetchDataSource = self
        feedRefreshController?.refresh()
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
