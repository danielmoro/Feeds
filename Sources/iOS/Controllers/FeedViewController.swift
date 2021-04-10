//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedRefreshController: FeedRefreshViewController?
    private var imageLoader: FeedImageLoader?
    private var cellControllers: [IndexPath: FeedImageCellController] = [:]
    private var tableModel: [FeedImage] = [] {
        didSet {
            tableView.reloadData()
        }
    }

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
        let cellController = FeedImageCellController(feedImage: tableModel[indexPath.row], loader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController.view
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cellController = FeedImageCellController(feedImage: tableModel[indexPath.row], loader: imageLoader!)
            cellController.prefetch()
            cellControllers[indexPath] = cellController
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cellControllers[indexPath] = nil
        }
    }
}
