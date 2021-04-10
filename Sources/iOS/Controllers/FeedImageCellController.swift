//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

public class FeedImageCellController {
    private var task: FeedImageLoadTask?
    private var feedImage: FeedImage
    private var loader: FeedImageLoader

    init(feedImage: FeedImage, loader: FeedImageLoader) {
        self.feedImage = feedImage
        self.loader = loader
    }

    deinit {
        task?.cancel()
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.descriptionLabel.text = feedImage.description
        cell.locationLabel.text = feedImage.location
        cell.locationContainer.isHidden = feedImage.location == nil
        cell.imageContentView.image = nil
        cell.reloadButton.isHidden = true
        cell.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.task = self.loader.loadImageData(from: self.feedImage.url) { result in

                if let data = try? result.get(), let image = UIImage(data: data) {
                    cell.imageContentView.image = image
                } else {
                    cell.reloadButton.isHidden = false
                }

                cell.stopShimmering()
            }
        }

        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    func prefetch() {
        task = loader.loadImageData(from: feedImage.url, completion: { _ in })
    }
}
