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

    func test_loadError_GenerateConnectivityError() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        let expectedError = NSError(domain: "Test", code: 0, userInfo: nil)

        var resultError: RemoteFeedLoader.Error?
        sut.load(completion: { error in
            resultError = error
        })

        client.expectToComplete(with: expectedError)
        client.completions[0](expectedError)

        XCTAssertEqual(resultError, RemoteFeedLoader.Error.connectivity)
    }

    // MARK: - Helpers

    private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)

        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        var completions: [(Error?) -> Void] = []

        func get(from url: URL, completion: @escaping (Error?) -> Void) {
            completions.append(completion)
            requestedURLs.append(url)
        }

        func expectToComplete(with error: Error?, at index: Int = 0) {
            completions[index](error)
        }
    }
}
