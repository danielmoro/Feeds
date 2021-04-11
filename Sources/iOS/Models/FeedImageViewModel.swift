//
//  Created by Daniel Moro on 11.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

final class FeedImageViewModel {
    private var task: FeedImageLoadTask?
    private var model: FeedImage
    private var loader: FeedImageLoader

    var description: String? {
        model.description
    }

    var location: String? {
        model.location
    }

    var hasLocation: Bool {
        model.location != nil
    }

    var onImageLoadingStateChange: ((Bool) -> Void)?
    var onShouldRetryImageLoad: ((Bool) -> Void)?
    var onImageLoad: ((UIImage) -> Void)?

    init(model: FeedImage, loader: FeedImageLoader) {
        self.model = model
        self.loader = loader
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
        if let data = try? result.get(), let image = UIImage(data: data) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoad?(true)
        }

        onImageLoadingStateChange?(false)
    }
}
