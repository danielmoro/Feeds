//
//  Created by Daniel Moro on 11.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

final class FeedImageViewModel {
    private var task: FeedImageLoadTask?
    private var feedImage: FeedImage
    private var loader: FeedImageLoader

    var image: UIImage?
    var description: String? {
        feedImage.description
    }

    var location: String? {
        feedImage.location
    }

    var hasLocation: Bool {
        feedImage.location != nil
    }

    var onLoad: ((Bool) -> Void)?

    init(model: FeedImage, loader: FeedImageLoader) {
        feedImage = model
        self.loader = loader
    }

    func load() {
        onLoad?(true)
        task = loader.loadImageData(from: feedImage.url) { [weak self] result in

            if let data = try? result.get(), let image = UIImage(data: data) {
                self?.image = image
            } else {}

            self?.onLoad?(false)
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    func preload() {
        task = loader.loadImageData(from: feedImage.url, completion: { _ in })
    }
}
