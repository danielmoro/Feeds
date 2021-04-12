//
//  Created by Daniel Moro on 11.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import Foundation

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void

    private var task: FeedImageLoadTask?
    private var model: FeedImage
    private var loader: FeedImageLoader
    private var imageTransformer: (Data) -> Image?

    var description: String? {
        model.description
    }

    var location: String? {
        model.location
    }

    var hasLocation: Bool {
        model.location != nil
    }

    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoad: Observer<Bool>?
    var onImageLoad: Observer<Image>?

    init(model: FeedImage, loader: FeedImageLoader, imageTransformer: @escaping ((Data) -> Image?)) {
        self.model = model
        self.loader = loader
        self.imageTransformer = imageTransformer
    }

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoad?(false)
        task = loader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result: result)
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    private func handle(result: Result<Data, Error>) {
        if let data = try? result.get(), let image = imageTransformer(data) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoad?(true)
        }

        onImageLoadingStateChange?(false)
    }
}
