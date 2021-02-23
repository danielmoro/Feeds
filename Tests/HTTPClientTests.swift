//
//  Created by Daniel Moro on 18.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import Foundation
import XCTest

class URLSessionHTTPClient: HTTPClient {
    init() {}

    func get(from url: URL, completion: ((HTTPClientResult) -> Void)? = nil) {
        let task = URLSession.shared.dataTask(with: url) { _, _, error in
            if let error = error {
                completion?(.failure(error))
            }
        }

        task.resume()
    }
}

class HTTPClientTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingURLRequests()
    }

    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingURLRequests()
    }

    func test_get_failsOnURLError() {
        let url = URL(string: "http://a-url.com")!
        let excpectedError = NSError(domain: "test error", code: 1)

        URLProtocolStub.stub(url: url, error: excpectedError)

        let expectation = XCTestExpectation(description: "Wait forcompletion")
        makeSUT().get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.code, excpectedError.code)
                XCTAssertEqual(receivedError.domain, excpectedError.domain)
            default:
                XCTFail("expected failure with \(excpectedError), got \(result) instead")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_get_generateGETRequest() {
        let url = URL(string: "http://a-url.com")!
        URLProtocolStub.stub(url: url, error: nil)

        let expectation = XCTestExpectation(description: "Wait for response")
        URLProtocolStub.handleRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }

        makeSUT().get(from: url)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Helpers

    private func makeSUT() -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()

        return sut
    }
}
