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

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageResult) -> Void) -> FeedImageLoadTask {
        client.get(from: url) { result in
            switch result {
            case let .success((response, data)):
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
    func test_init_doesNotPerformAnyURLRequests() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requestedURLs.count, 0)
    }

    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        _ = sut.loadImageData(from: url, completion: { _ in })

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(from: url, completion: { _ in })
        _ = sut.loadImageData(from: url, completion: { _ in })

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_loadImageDataFromURL_generatesErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toFinishWith: .failure(RemoteFeedImageLoader.Error.connectivity)) {
            client.complete(with: anyNSError())
        }
    }

    func test_loadImageDataFromURL_generatesInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let sampleCodes = [199, 201, 300, 400, 500]
        let validData = Data("non-empty content".utf8)

        sampleCodes.enumerated().forEach { index, code in
            expect(sut, toFinishWith: .failure(RemoteFeedImageLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, data: validData, at: index)
            }
        }
    }

    func test_loadImageDataFromURL_generatesInvalidDataErrorOnEmptyData() {
        let (sut, client) = makeSUT()
        let emptyData = Data()

        expect(sut, toFinishWith: .failure(RemoteFeedImageLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }

    func test_loadImageDataFromURL_deliversNonEmptyDataOnSuccessfulCompletion() {
        let (sut, client) = makeSUT()
        let validData = Data("non-empty content".utf8)

        expect(sut, toFinishWith: .success(validData)) {
            client.complete(withStatusCode: 200, data: validData)
        }
    }

//

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(client: client)
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func expect(
        _ sut: RemoteFeedImageLoader,
        toFinishWith expectedResult: RemoteFeedImageLoader.FeedImageResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Wait for load completion")
        let url = anyURL()
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
