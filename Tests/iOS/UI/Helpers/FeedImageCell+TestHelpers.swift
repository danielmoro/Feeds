//
//  FeedImageCell+TestHelpers.swift
//  Feeds_iOSTests
//
//  Created by Daniel Moro on 2.5.21..
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds_iOS
import UIKit

extension FeedImageCell {
    var descriptionText: String? {
        descriptionLabel.text
    }

    var locationText: String? {
        locationLabel.text
    }

    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }

    var isShowingLoadingIndicator: Bool {
        isShimmering == true
    }

    var renderedImage: Data? {
        imageContentView.image?.pngData()
    }

    var isShowingRetryAction: Bool {
        !reloadButton.isHidden
    }

    func simulateRetryAction() {
        reloadButton.simulateTap()
    }
}
