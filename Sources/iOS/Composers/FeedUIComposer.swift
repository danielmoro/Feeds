//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public final class FeedUIComposer {
    private init() {}
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)

        return feedController
    }

    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageLoader) -> (([FeedImage]) -> Void) {
        return { [weak controller] result in
            controller?.tableModel = result.map { model in
                FeedImageCellController(model: model, loader: loader)
            }
        }
    }
}
