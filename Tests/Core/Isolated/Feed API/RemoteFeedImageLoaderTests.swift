//
//  Created by Daniel Moro on 6.6.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import XCTest

class RemoteFeedImageLoader: FeedImageLoader {
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private struct RemoteFeedImageLoadTask: FeedImageLoadTask {
        func cancel() {}
    }

    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageResult) -> Void) -> FeedImageLoadTask {
        httpClient.get(from: url) { result in
            switch result {
            case let .success(response, data):
                if response.statusCode == 200, !data.isEmpty {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }

        return RemoteFeedImageLoadTask()
    }
}

class RemoteFeedImageLoaderTests: XCTestCase {
    func test_load_generatesErrorOnConnectionFailed() {
        let (sut, client) = makeSUT()

        expect(sut, loadDataFrom: anyURL(), toFinishWith: .failure(RemoteFeedImageLoader.Error.connectivity)) {
            client.complete(with: anyNSError())
        }
    }

    func test_load_generatesErrorOnInvalidData() {
        let (sut, client) = makeSUT()

        expect(sut, loadDataFrom: anyURL(), toFinishWith: .failure(RemoteFeedImageLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: Data())
        }
    }

    func test_load_deliversValidImageOnSuccessfulCompletion() {
        let (sut, client) = makeSUT()
        let validData = Data("non-empty content".utf8)

        expect(sut, loadDataFrom: anyURL(), toFinishWith: .success(validData)) {
            client.complete(withStatusCode: 200, data: validData)
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: RemoteFeedImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(httpClient: client)

        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: ((HTTPClient.Result) -> Void)?)] = []

        func get(from url: URL, completion: ((HTTPClient.Result) -> Void)?) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion?(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion?(.success((response, data)))
        }
    }

    func expect(
        _ sut: RemoteFeedImageLoader,
        loadDataFrom url: URL,
        toFinishWith expectedResult: RemoteFeedImageLoader.FeedImageResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (
                .failure(receivedError as RemoteFeedImageLoader.Error),
                .failure(expectedError as RemoteFeedImageLoader.Error)
            ):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) received \(receivedResult)", file: file, line: line)
            }

            expectation.fulfill()
        }

        action()

        wait(for: [expectation], timeout: 1)
    }
}
