//
//  Created by Daniel Moro on 4.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

final class FeedImageCellComposer {
    public static func feedImageCellComposedWith(model: FeedImage, loader: FeedImageLoader) -> FeedImageCellController {
        let adapter = FeedImageCellPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, loader: loader)
        let controller = FeedImageCellController(delegate: adapter)
        adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(controller), imageTransformer: UIImage.init)
        return controller
    }
}
