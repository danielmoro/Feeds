//
//  Created by Daniel Moro on 31.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

class FeedImageCell: UITableViewCell {
    @IBOutlet var locationContainer: UIView?
    @IBOutlet var locationLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet var imageContentView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageContentView?.alpha = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageContentView?.alpha = 0
    }

    func fadeIn(image: UIImage?) {
        imageContentView?.image = image
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.3, options: []) {
            self.imageContentView?.alpha = 1
        }
    }
}
