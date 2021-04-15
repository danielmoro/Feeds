//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    @IBOutlet public var locationContainer: UIView!
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var imageContentView: UIImageView!
    @IBOutlet public var reloadButton: UIButton!

    public var onRetry: (() -> Void)?

    @IBAction
    private func reloadButtonTapped() {
        onRetry?()
    }
}
