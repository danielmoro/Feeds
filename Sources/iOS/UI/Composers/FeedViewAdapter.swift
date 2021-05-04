//
//  Created by Daniel Moro on 4.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import Foundation

final class FeedViewAdapter: FeedView {
    init(controller: FeedViewController, loader: FeedImageLoader) {
        self.controller = controller
        self.loader = loader
    }

    private weak var controller: FeedViewController?
    private var loader: FeedImageLoader

    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            FeedImageCellComposer.feedImageCellComposedWith(model: model, loader: loader)
        }
    }
}
