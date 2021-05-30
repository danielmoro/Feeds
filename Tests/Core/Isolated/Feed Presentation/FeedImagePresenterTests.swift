//
//  Created by Daniel Moro on 30.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import XCTest

class FeedImagePresenterTests: XCTestCase {
    func test_init_presentsNoMessages() {
        let (_, view) = makeSUT()
        XCTAssertEqual(view.messages.isEmpty, true)
    }

    func test_didStartLoadingImageData_presentsModel() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        sut.didStartLoadingImageData(for: image)

        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, false)
    }

    func test_didFailLoadingImageData_displaysRetry() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        sut.didFailLoadingImageData(with: anyNSError(), for: image)

        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
    }

    func test_didFinishLoadingImageData_displaysRetryWhenImageTransformationFails() {
        let (sut, view) = makeSUT(imageTransformer: { _ in nil })
        let image = uniqueImage()
        sut.didFinishLoadingImageData(with: Data(), for: image)

        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
    }

    func test_didFinishLoadingImageData_displaysImageWhenImageTransformationSucceeds() {
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        let image = uniqueImage()
        sut.didFinishLoadingImageData(with: Data(), for: image)

        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.image, transformedData)
        XCTAssertEqual(message?.shouldRetry, false)
    }

    // MARK: - Helpers

    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackMemoryLeaks(view, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    private class ViewSpy: FeedImageView {
        var messages: [FeedImageModel<AnyImage>] = []

        func display(_ model: FeedImageModel<AnyImage>) {
            messages.append(model)
        }
    }

    private struct AnyImage: Equatable {}
}
