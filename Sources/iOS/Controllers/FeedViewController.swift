//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    @IBOutlet var feedRefreshController: FeedRefreshViewController?
    var tableModel: [FeedImageCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = feedRefreshController?.view

        feedRefreshController?.refresh()
    }

    private func cellController(atIndexPath indexPath: IndexPath) -> FeedImageCellController {
        tableModel[indexPath.row]
    }

    private func cancelCellControllerLoad(atIndexPath indexPath: IndexPath) {
        tableModel[indexPath.row].cancelLoad()
    }

    // MARK: - UITableViewDataSource

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controller = cellController(atIndexPath: indexPath)
        return controller.view(in: tableView)
    }

    // MARK: - UITableViewDelegate

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(atIndexPath: indexPath)
    }

    // MARK: - UITableViewDataSourcePrefetching

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let controller = cellController(atIndexPath: indexPath)
            controller.prefetch()
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cancelCellControllerLoad(atIndexPath: indexPath)
        }
    }
}
