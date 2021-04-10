//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedRefreshController: FeedRefreshViewController?
    private var tableModel: [FeedImageCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageLoader) {
        self.init()
        feedRefreshController = FeedRefreshViewController(feedLoader: feedLoader)
        feedRefreshController?.onRefresh = { [weak self] result in
            self?.tableModel = result.map { model in
                FeedImageCellController(model: model, loader: imageLoader)
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = feedRefreshController?.view

        tableView.prefetchDataSource = self
        feedRefreshController?.refresh()
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(atIndexPath: indexPath)
        return cellController.view()
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(atIndexPath: indexPath)
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cellController = cellController(atIndexPath: indexPath)
            cellController.prefetch()
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cancelCellControllerLoad(atIndexPath: indexPath)
        }
    }

    func cellController(atIndexPath indexPath: IndexPath) -> FeedImageCellController {
        tableModel[indexPath.row]
    }

    func cancelCellControllerLoad(atIndexPath indexPath: IndexPath) {
        tableModel[indexPath.row].cancelLoad()
    }
}
