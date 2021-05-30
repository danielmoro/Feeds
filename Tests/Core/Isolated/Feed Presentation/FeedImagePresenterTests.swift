//
//  Created by Daniel Moro on 30.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import XCTest

struct FeedImageModel {
    var description: String?
    var location: String?
    var image: Any?
    var isLoading: Bool
    var shouldRetry: Bool
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    // associatedtype Image
    func display(_ model: FeedImageModel)
}

final class FeedImagePresenter {
    private let view: FeedImageView

    init(view: FeedImageView) {
        self.view = view
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        ))
    }

    func didFinishLoadingImageData(with _: Data, for model: FeedImage) {
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true
        ))
    }

    func didFailLoadingImageData(with _: Error, for model: FeedImage) {
        view.display(FeedImageModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true
        ))
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_presentsNoMessages() {
        let (_, view) = makeSUT()
        XCTAssertEqual(view.messages.isEmpty, true)
    }

    func test_didStartLoadingImageData_presentsModel() {
        let (sut, view) = makeSUT()
        let model = uniqueImage()
        sut.didStartLoadingImageData(for: model)

        let message = view.messages.first
        XCTAssertEqual(message?.description, model.description)
        XCTAssertEqual(message?.location, model.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, false)
    }

    func test_didFailLoadingImageData_displaysRetry() {
        let (sut, view) = makeSUT()
        let model = uniqueImage()
        sut.didFailLoadingImageData(with: anyNSError(), for: model)

        let message = view.messages.first
        XCTAssertEqual(message?.description, model.description)
        XCTAssertEqual(message?.location, model.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
    }

    func test_didFinishLoadingImageData_displaysRetryWhenImageTransformationfails() {
        let (sut, view) = makeSUT()
        let model = uniqueImage()
        sut.didFinishLoadingImageData(with: Data(), for: model)

        let message = view.messages.first
        XCTAssertEqual(message?.description, model.description)
        XCTAssertEqual(message?.location, model.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
    }

//    func test_didFinishLoadingImageData_displaysImage() {
//        let (sut, view) = makeSUT()
//        let model = uniqueImage()
//        let imageData = UIImage.make(withColor: UIColor.red.cgColor).pngData()!
//        sut.didFinishLoadingImageData(with: imageData, for: model)
//
//        let message = view.messages.first
//        XCTAssertEqual(message?.description, model.description)
//        XCTAssertEqual(message?.location, model.location)
//        XCTAssertEqual(message?.isLoading, true)
//        XCTAssertNil(message?.image)
//        XCTAssertEqual(message?.shouldRetry, false)
//    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackMemoryLeaks(view, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    private class ViewSpy: FeedImageView {
        var messages: [FeedImageModel] = []

        func display(_ model: FeedImageModel) {
            messages.append(model)
        }
    }
}
