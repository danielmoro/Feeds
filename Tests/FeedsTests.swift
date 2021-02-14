//
//  FeedsTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 13.2.21..
//

import XCTest

class RemoteFeedLoader {
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    let client: HTTPClient
    let url: URL

    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class FeedsTests: XCTestCase {
    func test_init_doesNotFetchURL() {
        let url = URL(string: "http://a-url.com")!
        let (_, client) = makeSUT(url: url)

        XCTAssertNil(client.requestedURL)
    }

    func test_load_fetchesProperURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(url, client.requestedURL)
    }

    // MARK: - Helpers

    private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)

        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?

        func get(from url: URL) {
            requestedURL = url
        }
    }
}
