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

    func test_load_generateConnectivityErrorOnError() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        expect(sut, toFailWithError: RemoteFeedLoader.Error.connectivity) {
            let expectedError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: expectedError)
        }
    }

    func test_load_generateErrorOnNon200HTTPResponse() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        let sampleCodes = [199, 201, 300, 400, 500]

        sampleCodes.enumerated().forEach { index, code in
            expect(sut, toFailWithError: RemoteFeedLoader.Error.invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }

    func test_load_generateErrorOn200HTTPResponseWithInvalidJSON() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        expect(sut, toFailWithError: RemoteFeedLoader.Error.invalidData) {
            let json = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: json)
        }
    }

    // MARK: - Helpers

    private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)

        return (sut, client)
    }

    func expect(
        _ sut: RemoteFeedLoader,
        toFailWithError error: RemoteFeedLoader.Error,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut.load(completion: { result in
            capturedResults.append(result)
        })

        action()

        XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
    }

    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []

        var requestedURLs: [URL] {
            messages.map(\.url)
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(response, data))
        }
    }
}
