//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public class FeedRefreshViewController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())

    var viewModel: FeedViewModel

    @objc func refresh() {
        viewModel.loadFeed()
    }

    internal init(_ viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingChange = { isLoading in
            if isLoading {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
        }

        view.addTarget(self, action: #selector(refresh), for: .valueChanged)

        return view
    }
}
