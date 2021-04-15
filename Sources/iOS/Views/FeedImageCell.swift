//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    @IBOutlet var locationContainer: UIView?
    @IBOutlet var locationLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet var imageContentView: UIImageView?
    @IBOutlet var reloadButton: UIButton?

    public var onRetry: (() -> Void)?

    @IBAction
    private func reloadButtonTapped() {
        onRetry?()
    }
}
