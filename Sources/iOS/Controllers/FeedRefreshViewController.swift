//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    private var feedLoader: FeedLoader
    private var onLoad: ((Result<[FeedImage], Error>) -> Void)?

    internal init(feedLoader: FeedLoader, onLoad: ((Result<[FeedImage], Error>) -> Void)? = nil) {
        self.feedLoader = feedLoader
        self.onLoad = onLoad
        super.init()
    }

    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load(completion: { [weak self] result in
            self?.onLoad?(result)
            self?.view.endRefreshing()
        })
    }
}
