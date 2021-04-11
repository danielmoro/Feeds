//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

public class FeedImageCellController {
    private var viewModel: FeedImageViewModel

    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.descriptionLabel.text = viewModel.description
        cell.locationLabel.text = viewModel.location
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.imageContentView.image = nil
        cell.reloadButton.isHidden = true

        viewModel.onLoad = { [weak self, weak cell] isLoading in
            if isLoading {
                cell?.startShimmering()
            } else {
                cell?.stopShimmering()
                if let image = self?.viewModel.image {
                    cell?.imageContentView.image = image
                } else {
                    cell?.reloadButton.isHidden = false
                }
            }
        }

        viewModel.load()

        cell.onRetry = viewModel.load

        return cell
    }

    func prefetch() {
        viewModel.preload()
    }

    func cancelLoad() {
        viewModel.cancel()
    }
}
