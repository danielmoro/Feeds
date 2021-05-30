//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public class FeedImageCellController: FeedImageView {
    private(set) var cell: FeedImageCell?
    private let delegate: FeedImageCellControllerDelegate

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    public func display(_ model: FeedImageModel<UIImage>) {
        cell?.descriptionLabel.text = model.description
        cell?.locationLabel.text = model.location
        cell?.locationContainer.isHidden = !model.hasLocation
        cell?.imageContentView.setImageAnimated(model.image)
        cell?.reloadButton.isHidden = !model.shouldRetry
        cell?.isShimmering = model.isLoading
        cell?.onRetry = delegate.didRequestImage
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }

    func prefetch() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        cleanupCellForReuse()
        delegate.didCancelImageRequest()
    }

    func cleanupCellForReuse() {
        cell = nil
    }
}
