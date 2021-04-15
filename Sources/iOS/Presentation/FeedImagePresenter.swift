//
//  Created by Daniel Moro on 13.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

struct FeedImageModel<Image> {
    var description: String?
    var location: String?
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageModel<Image>)
}

final class FeedImagePresenter<View, Image> where View: FeedImageView, View.Image == Image {
    private var imageTransformer: (Data) -> Image?

    var view: View

    init(view: View, imageTransformer: @escaping ((Data) -> Image?)) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        ))
    }

    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        ))
    }

    func didFailLoadingImageData(with _: Error, for model: FeedImage) {
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true
        ))
    }
}
