//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds_iOS
import FeedsCore
import UIKit
import XCTest

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedLoad() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.feedRequests.count, 0, "Expect no loading request before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.feedRequests.count, 1, "Expect loading reqest once view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.feedRequests.count, 2, "Expect another loading request after user initiated reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            loader.feedRequests.count,
            3,
            "Expect yet another loading request after another user initiated reload"
        )
    }

    func test_loadFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            true,
            "Expect loading indicator to be visible once view is loaded"
        )

        loader.complete(at: 0)
        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            false,
            "Expect loading indicator no to be visible after load is complete succesfully"
        )

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            true,
            "Expect loading indicator to be visible user initiated reload"
        )

        loader.complete(withError: anyNSError(), at: 1)
        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            false,
            "Expect loading indicator note no to be visible after user initiated load is complete with error"
        )
    }

    func test_loadFeedCompletion_RendersSuccefullyLoadedFeed() {
        let image0 = makeImage(description: "decription", location: "location")
        let image1 = makeImage(description: nil, location: "location")
        let image2 = makeImage(description: "decription", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        assertThat(sut, isRendering: [])

        loader.complete(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedFeedReload()

        loader.complete(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }

    func test_loadFeedCompletion_doesNotAlterRenderedViewsOnError() {
        let image0 = makeImage(description: "decription", location: "location")
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.complete(with: [image0], at: 0)

        sut.simulateUserInitiatedFeedReload()

        loader.complete(withError: anyNSError(), at: 1)

        assertThat(sut, isRendering: [image0])
    }

    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.complete(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URLs loaded until view is visible")

        sut.simulateFeedImageViewVisible(at: 0)

        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image became visible")

        sut.simulateFeedImageViewVisible(at: 1)

        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image became visible")
    }

    // MARK: - Helpers

    class LoaderSpy: FeedLoader, FeedImageLoader {
        // MARK: - FeedLoader

        var feedRequests: [(FeedLoader.Result) -> Void] = []

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }

        func complete(with images: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(images))
        }

        func complete(withError error: Error, at index: Int) {
            feedRequests[index](.failure(error))
        }

        // MARK: - FeedImageLoader

        var loadedImageURLs: [URL] = []

        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
    }

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeImage(
        description: String? = nil,
        location: String? = nil,
        url: URL = URL(string: "http://any-url.com")!
    ) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    private func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.feedImageView(at: index)

        guard let cell = view as? FeedImageCell else {
            return XCTFail(
                "Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead",
                file: file,
                line: line
            )
        }

        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(
            cell.isShowingLocation,
            shouldLocationBeVisible,
            "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))",
            file: file,
            line: line
        )

        XCTAssertEqual(
            cell.locationText,
            image.location,
            "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))",
            file: file,
            line: line
        )

        XCTAssertEqual(
            cell.descriptionText,
            image.description,
            """
            Expected description text to be \(String(describing: image.description)) \
            for image view at index (\(index)
            """,
            file: file,
            line: line
        )
    }

    private func assertThat(
        _ sut: FeedViewController,
        isRendering images: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedFeedImageViews == images.count else {
            XCTFail(
                "Expected \(images.count) images, got \(sut.numberOfRenderedFeedImageViews) instead",
                file: file,
                line: line
            )
            return
        }

        images.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension FeedViewController {
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

    func simulateFeedImageViewVisible(at index: Int) {
        _ = feedImageView(at: index)
    }
}

private extension FeedImageCell {
    var descriptionText: String? {
        descriptionLabel.text
    }

    var locationText: String? {
        locationLabel.text
    }

    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
}
