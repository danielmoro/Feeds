//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView {
    var delegate: FeedViewControllerDelegate?
    var tableModel: [FeedImageCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        title = "Feed"

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        refresh()
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

    // MARK: - FeedLoadingView

    @objc func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    func display(isLoading: Bool) {
        if isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}
