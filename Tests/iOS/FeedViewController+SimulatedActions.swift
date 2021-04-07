//
//  Created by Daniel Moro on 7.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds_iOS
import UIKit

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }

    var numberOfRenderedFeedImageViews: Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }

    var feedImagesSection: Int {
        0
    }

    func feedImageView(at index: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }

    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }

    func simulateFeedImageViewHidden(at index: Int) {
        let view = feedImageView(at: index)
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        tableView.delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }

    func simulateFeedImageViewNearVisible(at index: Int) {
        let dataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        dataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }

    func simulateFeedImageViewNotNearVisible(at index: Int) {
        simulateFeedImageViewNearVisible(at: index)

        let dataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
}

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
