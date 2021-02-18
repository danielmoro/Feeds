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

    func get(from url: URL, completion _: ((HTTPClientResult) -> Void)? = nil) {
        let task = session.dataTask(with: url) { _, _, _ in
        }

        task.resume()
    }
}

class HTTPClientTests: XCTestCase {
    func test_get_createsDataTaskWithURL() {
        let sessionSpy = URLSessionSpy()
        let url = URL(string: "http://a-url.com")!
        let sut = URLSessionHTTPClient(session: sessionSpy)

        sut.get(from: url)

        XCTAssertEqual(sessionSpy.urls, [url])
    }

    func test_get_resumesDataTaskWithURL() {
        let sessionSpy = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let url = URL(string: "http://a-url.com")!
        sessionSpy.stubs[url] = task
        let sut = URLSessionHTTPClient(session: sessionSpy)

        sut.get(from: url)

        XCTAssertEqual(task.resumeCount, 1)
    }

    private class URLSessionSpy: URLSession {
        var urls: [URL] = []
        var stubs: [URL: URLSessionDataTask] = [:]

        override func dataTask(with url: URL, completionHandler _: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            urls.append(url)

            if let task = stubs[url] {
                return task
            } else {
                return FakeURLSessionDataTask()
            }
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
