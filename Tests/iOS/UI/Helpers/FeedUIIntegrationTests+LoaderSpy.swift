//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  Feeds_iOSTests
//
//  Created by Daniel Moro on 2.5.21..
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds_iOS
import FeedsCore
import Foundation

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
