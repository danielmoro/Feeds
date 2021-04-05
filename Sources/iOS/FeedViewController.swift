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
}

public protocol FeedImageLoadTask {
    func cancel()
}

public protocol FeedImageLoader {
    func loadImageData(from url: URL) -> FeedImageLoadTask
}

public class FeedViewController: UITableViewController {
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
        tasks[indexPath] = imageLoader?.loadImageData(from: feedImage.url)

        return cell
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}
