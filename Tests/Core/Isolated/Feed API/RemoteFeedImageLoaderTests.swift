//
//  Created by Daniel Moro on 6.6.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import XCTest

class RemoteFeedImageLoader: FeedImageLoader {
    enum Error: Swift.Error {
        case connectionFailed
    }

    private struct RemoteFeedImageLoadTask: FeedImageLoadTask {
        func cancel() {}
    }

    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func loadImageData(from _: URL, completion: @escaping (FeedImageResult) -> Void) -> FeedImageLoadTask {
        completion(.failure(Error.connectionFailed))
        return RemoteFeedImageLoadTask()
    }
}

class RemoteFeedImageLoaderTests: XCTestCase {
    func test_load_returnsErrorOnConnectionFailed() {
        let (sut, _) = makeSUT()

        var receivedResult: RemoteFeedImageLoader.FeedImageResult?
        let exp = expectation(description: "Wait for load to finish")
        _ = sut.loadImageData(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }

//        client.finishWith(error: connectionFailureError, at: 0)

        wait(for: [exp], timeout: 1)
        switch receivedResult {
        case .none:
            XCTFail("Expected failure, got empty")
        case .success:
            XCTFail("Expected failure, got data")
        case let .failure(error):
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: FeedImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(httpClient: client)

        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var completions: [((HTTPClient.Result) -> Void)?] = []
        func get(from _: URL, completion: ((HTTPClient.Result) -> Void)?) {
            completions.append(completion)
        }

        func finishWith(error: Error, at index: Int) {
            completions[index]?(.failure(error))
        }
    }
}
