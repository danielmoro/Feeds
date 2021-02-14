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

class HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class FeedsTests: XCTestCase {
    
    func test_init_doesNotFetchURL() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClient()
        _ = RemoteFeedLoader(url: url, client: client)

        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_fetchesProperURL() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
