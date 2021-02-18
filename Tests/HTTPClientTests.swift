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
    func test_get_failsOnURLError() {
        URLProtocolStub.startInterceptingURLRequests()
        let url = URL(string: "http://a-url.com")!
        let excpectedError = NSError(domain: "test error", code: 1)

        URLProtocolStub.stub(url: url, error: excpectedError)
        let sut = URLSessionHTTPClient()

        let expectation = XCTestExpectation(description: "Wait forcompletion")
        sut.get(from: url) { result in
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
        URLProtocolStub.stopInterceptingURLRequests()
    }

    // MARK: - Helpers

    private class URLProtocolStub: URLProtocol {
        private static var stubs: [URL: Stub] = [:]

        private struct Stub {
            var error: Error?
            var data: Data?
            var response: URLResponse?
        }

        static func stub(url: URL, error: Error?) {
            stubs[url] = Stub(error: error)
        }

        static func startInterceptingURLRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingURLRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }

        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }

            return stubs[url] != nil
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
