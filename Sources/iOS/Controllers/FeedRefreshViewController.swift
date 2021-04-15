//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

protocol FeedRefreshDelegate {
    func didRequestFeedRefresh()
}

public class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view = loadView()

    private let delegate: FeedRefreshDelegate

    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }

    internal init(_ delegate: FeedRefreshDelegate) {
        self.delegate = delegate
    }

    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }

    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
