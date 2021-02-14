//
//  FeedsTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 13.2.21..
//

import XCTest

class RemoteFeedLoader {}

class HTTPClient {
    var remoteFeedURL: URL?
}

class FeedsTests: XCTestCase {
    func test_init_doesNotFetchURL() {
        _ = RemoteFeedLoader()
        let client = HTTPClient()

        XCTAssertNil(client.remoteFeedURL)
    }
}
