//
//  Created by Daniel Moro on 1.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds_iOS
import FeedsCore
import UIKit
import XCTest

final class FeedViewControllerTests: XCTestCase {
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        let localizedString = localize("FEED_TITLE_VIEW", table: "Feeds")
        XCTAssertEqual(sut.title, localizedString)
    }

    func test_loadFeedActions_requestFeedLoad() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.feedRequests.count, 0, "Expect no loading request before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.feedRequests.count, 1, "Expect loading reqest once view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.feedRequests.count, 2, "Expect another loading request after user initiated reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.feedRequests.count, 3, "Expect yet another loading request after another user initiated reload")
    }

    func test_loadFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expect loading indicator to be visible once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expect loading indicator no to be visible after load is complete succesfully")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expect loading indicator to be visible user initiated reload")

        loader.completeFeedLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expect loading indicator note no to be visible after user initiated load is complete with error")
    }

    func test_loadFeedCompletion_RendersSuccefullyLoadedFeed() {
        let image0 = makeImage(description: "decription", location: "location")
        let image1 = makeImage(description: nil, location: "location")
        let image2 = makeImage(description: "decription", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        assertThat(sut, isRendering: [])

        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedFeedReload()

        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }

    func test_loadFeedCompletion_doesNotAlterRenderedViewsOnError() {
        let image0 = makeImage(description: "decription", location: "location")
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0], at: 0)

        sut.simulateUserInitiatedFeedReload()

        loader.completeFeedLoading(with: anyNSError(), at: 1)

        assertThat(sut, isRendering: [image0])
    }

    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URLs loaded until view is visible")

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image became visible")

        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image became visible")
    }

    func test_feedImageView_cancelsImageLoadWhenViewIsNoLongerVisible() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no image URLs cacnelled until view is hidden")

        sut.simulateFeedImageViewHidden(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first image URL cancelled once first image is no longer visible")

        sut.simulateFeedImageViewHidden(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second image URL cancelled once second image is no longer visible")
    }

    func test_feedImageViewLoadingIndicator_isVisibleWhieImageIsLoading() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true, "Expect to see loading indicator in the fist view once it bacomes visible")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expect to see loading indicator in the second view once it bacomes visible")

        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false,
                       "Expect loading indicator not to be visible in the fist view once loading completes succesfully")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false,
                       "Expect loading indicator not to be visible in the second view once loading completes with an error")
    }

    func test_feedImageView_rendersImageLoadedFromURL() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, nil, "Expect no image for the fist view while loading image")
        XCTAssertEqual(view1?.renderedImage, nil, "Expect no image for the the second view while loading image")

        let imageData0 = UIImage.make(withColor: UIColor.red.cgColor).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expect image for the fist view once loading completes succesfully")
        XCTAssertEqual(view1?.renderedImage, nil, "Expect no image for the the second view when fist view image is loaded")

        let imageData1 = UIImage.make(withColor: UIColor.blue.cgColor).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expect image for the fist view not to change when second finish loading succesfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expect image for the the second view once loading completes succesfully")
    }

    func test_feedImageViewReloadButton_isVisibleOnImageLoadError() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)

        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action on the fist view while image is loading")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expect no retry action on the second view while image is loading")

        let imageData0 = UIImage.make(withColor: UIColor.red.cgColor).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action on the fist view if image load completes succesfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expect no state change on the second view if first view image load completes succesfully")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no state change on the first view if second view image load fails with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expect retry action on the second view if image load fails with error")
    }

    func test_feedImageViewReloadButton_isVisibleOnInvalidImageData() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action on the fist view while image is loading")

        let invalidImageData = Data()
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, true, "Expect retry action on the fist view if image load completes with invalid image data")
    }

    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL requests once two image views became visible")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected first image URL request again after first view retry action")

        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url],
                       "Expected second image URL request again after second view retry action")
    }

    func test_feedImageView_preloadsImageURLWhenViewIsNearVisible() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URLs loaded until view is near visible")

        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }

    func test_feedImageView_cancelsImageURLRequestWhenViewIsNotNearVisible() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://another-image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no image URLs cancelled until view is not near visible")

        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected fist image URL request cancelled once image is not near visible anymore")

        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url],
                       "Expected second image URL request cancelled once image is not near visible anymore")
    }

    func test_feedImageView_doesNotRenderImageWhenViewIsNoLongerVisible() {
        let image0 = makeImage(url: URL(string: "https://image-url.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0], at: 0)
        let view0 = sut.simulateFeedImageViewHidden(at: 0)

        let imageData0 = UIImage.make(withColor: UIColor.red.cgColor).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)

        XCTAssertEqual(view0?.renderedImage, nil, "Expect no rendered images when load is finished after view is no longer visible")
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
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
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }

    // MARK: - Localization

    private func localize(
        _ key: String,
        table: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let bundle = Bundle(for: FeedViewController.self)
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
        XCTAssertNotEqual(key, localizedString, "Missing localization for \(key) in \(table)", file: file, line: line)
        return localizedString
    }
}

class LoaderSpy: FeedLoader, FeedImageLoader {
    // MARK: - FeedLoader

    var feedRequests: [(FeedLoader.Result) -> Void] = []

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }

    func completeFeedLoading(with images: [FeedImage] = [], at index: Int) {
        feedRequests[index](.success(images))
    }

    func completeFeedLoading(with error: Error, at index: Int) {
        feedRequests[index](.failure(error))
    }

    // MARK: - FeedImageLoader

    private class TaskSpy: FeedImageLoadTask {
        init(cancelCallback: @escaping () -> Void) {
            self.cancelCallback = cancelCallback
        }

        var cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }

    var imageLoadRequests: [(url: URL, completion: (FeedImageResult) -> Void)] = []
    var loadedImageURLs: [URL] {
        imageLoadRequests.map(\.url)
    }

    var cancelledImageURLs: [URL] = []

    func loadImageData(from url: URL, completion: @escaping (FeedImageResult) -> Void) -> FeedImageLoadTask {
        imageLoadRequests.append((url, completion))
        return TaskSpy { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }

    func completeImageLoading(with data: Data = Data(), at index: Int) {
        imageLoadRequests[index].completion(.success(data))
    }

    func completeImageLoadingWithError(at index: Int) {
        imageLoadRequests[index].completion(.failure(anyNSError()))
    }
}
