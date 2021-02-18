//
//  Created by Daniel Moro on 18.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import Foundation
import XCTest

class URLSessionHTTPClient: HTTPClient {
    private var session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL, completion: ((HTTPClientResult) -> Void)? = nil) {
        let task = session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion?(.failure(error))
            }
        }

        task.resume()
    }
}

class HTTPClientTests: XCTestCase {
    func test_get_resumesDataTaskWithURL() {
        let sessionSpy = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let url = URL(string: "http://a-url.com")!
        sessionSpy.stub(url: url, with: task, error: nil)
        let sut = URLSessionHTTPClient(session: sessionSpy)

        sut.get(from: url)

        XCTAssertEqual(task.resumeCount, 1)
    }

    func test_get_failsOnURLError() {
        let sessionSpy = URLSessionSpy()
        let url = URL(string: "http://a-url.com")!
        let task = URLSessionDataTaskSpy()
        let excpectedError = NSError(domain: "test error", code: 0)
        sessionSpy.stub(url: url, with: task, error: excpectedError)
        let sut = URLSessionHTTPClient(session: sessionSpy)

        let expectation = XCTestExpectation(description: "Wait forcompletion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, excpectedError)
            default:
                XCTFail("expected failure with \(excpectedError), got \(result) instead")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession {
        var urls: [URL] = []
        private var stubs: [URL: Stub] = [:]

        private struct Stub {
            var task: URLSessionDataTask
            var error: Error?
            var data: Data?
            var response: URLResponse?
        }

        func stub(url: URL, with task: URLSessionDataTask, error: Error?) {
            stubs[url] = Stub(task: task, error: error)
        }

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            urls.append(url)

            guard let stub = stubs[url] else {
                fatalError("cannot find stub for url \(url)")
            }

            completionHandler(stub.data, stub.response, stub.error)
            return stub.task
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {}

    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCount = 0

        override func resume() {
            resumeCount += 1
        }
    }
}
