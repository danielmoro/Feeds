//
//  Created by Daniel Moro on 13.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public struct FeedImageModel<Image> {
    public var description: String?
    public var location: String?
    public var image: Image?
    public var isLoading: Bool
    public var shouldRetry: Bool
    public var hasLocation: Bool {
        location != nil
    }
}

public protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageModel<Image>)
}

public final class FeedImagePresenter<View, Image> where View: FeedImageView, View.Image == Image {
    private var imageTransformer: (Data) -> Image?

    var view: View

    public init(view: View, imageTransformer: @escaping ((Data) -> Image?)) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        ))
    }

    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        ))
    }

    public func didFailLoadingImageData(with _: Error, for model: FeedImage) {
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true
        ))
    }
}
