//
//  Created by Daniel Moro on 4.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import Foundation

final class FeedImageCellPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    init(model: FeedImage, loader: FeedImageLoader) {
        self.model = model
        self.loader = loader
    }

    private var model: FeedImage
    private var task: FeedImageLoadTask?
    private var loader: FeedImageLoader

    var presenter: FeedImagePresenter<View, Image>?

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        task = loader.loadImageData(from: model.url, completion: { [weak self] resut in
            switch resut {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFailLoadingImageData(with: error, for: model)
            }
        })
    }

    func didCancelImageRequest() {
        task?.cancel()
    }
}
