//
//  FeedsTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 13.2.21..
//

import Feeds
import XCTest

class FeedsTests: XCTestCase {
    func test_init_doesNotFetchURL() {
        let url = URL(string: "http://a-url.com")!
        let (_, client) = makeSUT(url: url)

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_fetchesProperURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_fetchesProperURLsTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_generatesConnectivityErrorOnError() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        expect(sut, toFinishWith: failure(.connectivity)) {
            let expectedError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: expectedError)
        }
    }

    func test_load_generatesErrorOnNon200HTTPResponse() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        let sampleCodes = [199, 201, 300, 400, 500]

        sampleCodes.enumerated().forEach { index, code in
            expect(sut, toFinishWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: makeItemsJSON(items: []), at: index)
            }
        }
    }

    func test_load_generatesErrorOn200HTTPResponseWithInvalidJSON() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        expect(sut, toFinishWith: failure(.invalidData)) {
            let json = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: json)
        }
    }

    func test_load_generatesEmptyListon200HTTPResponswithEmptyJSON() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        expect(sut, toFinishWith: .success([])) {
            client.complete(withStatusCode: 200, data: makeItemsJSON(items: []))
        }
    }

    func test_load_generatesFeedListOn200HTTPResponseWithValidJSON() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        let image1 = makeFeedImage(
            id: UUID(),
            description: nil,
            location: nil,
            url: URL(string: "http://a-image-url.com")!
        )

        let image2 = makeFeedImage(
            id: UUID(),
            description: "item description",
            location: "item location",
            url: URL(string: "http://another-image-url.com")!
        )

        expect(sut, toFinishWith: .success([image1.model, image2.model])) {
            client.complete(withStatusCode: 200, data: makeItemsJSON(items: [image1.json, image2.json]))
        }
    }

    func test_load_doesNotCompleteWhenSUTIsDeallocated() {
        let url = URL(string: "http://a-given-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults: [FeedLoader.Result] = []
        sut?.load(completion: { result in
            capturedResults.append(result)
        })

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON(items: []))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func makeFeedImage(
        id: UUID, // swiftlint:disable:this identifier_name
        description: String? = nil,
        location: String? = nil,
        url: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let image = FeedImage(
            id: id,
            description: description,
            location: location,
            url: url
        )

        let json = [
            "id": image.id.uuidString,
            "description": image.description,
            "location": image.location,
            "image": image.url.absoluteString,
        ].compactMapValues { $0 }

        return (image, json)
    }

    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        let json = [
            "images": items,
        ]
        return try! JSONSerialization.data(withJSONObject: json, options: []) // swiftlint:disable:this force_try
    }

    private func failure(_ error: RemoteFeedLoader.Error) -> FeedLoader.Result {
        .failure(error)
    }

    func expect(
        _ sut: RemoteFeedLoader,
        toFinishWith expectedResult: FeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (
                .failure(receivedError as RemoteFeedLoader.Error),
                .failure(expectedError as RemoteFeedLoader.Error)
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

    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: ((HTTPClient.Result) -> Void)?)] = []

        var requestedURLs: [URL] {
            messages.map(\.url)
        }

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
}
