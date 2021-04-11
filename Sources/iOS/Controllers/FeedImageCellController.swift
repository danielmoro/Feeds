//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

public class FeedImageCellController {
    private var viewModel: FeedImageViewModel<UIImage>

    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }

    func prefetch() {
        viewModel.loadImageData()
    }

    func cancelLoad() {
        viewModel.cancel()
    }

    private func binded(_ view: FeedImageCell) -> UITableViewCell {
        view.descriptionLabel.text = viewModel.description
        view.locationLabel.text = viewModel.location
        view.locationContainer.isHidden = !viewModel.hasLocation
        view.imageContentView.image = nil

        viewModel.onShouldRetryImageLoad = { [weak view] shouldRetry in
            view?.reloadButton.isHidden = !shouldRetry
        }

        viewModel.onImageLoadingStateChange = { [weak view] isLoading in
            view?.isShimmering = isLoading
        }

        viewModel.onImageLoad = { [weak view] image in
            view?.imageContentView.image = image
        }

        view.onRetry = viewModel.loadImageData

        return view
    }
}
