//
//  Created by Daniel Moro on 18.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import Foundation
import XCTest

class HTTPClientTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingURLRequests()
    }

    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingURLRequests()
    }

    func test_get_failsOnRequestError() {
        let excpectedError = anyNSError()

        let receivedError = resultErrorFor(error: excpectedError, response: nil, data: nil) as NSError?
        XCTAssertEqual(receivedError?.code, excpectedError.code)
        XCTAssertEqual(receivedError?.domain, excpectedError.domain)
    }

    func test_get_failsOnAllInvalidUnexpectedCases() {
        XCTAssertNotNil(resultErrorFor(error: nil, response: nil, data: nil))
        XCTAssertNotNil(resultErrorFor(error: nil, response: anyNonHTTPURLResponse(), data: nil))
        XCTAssertNotNil(resultErrorFor(error: nil, response: nil, data: anyData()))
        XCTAssertNotNil(resultErrorFor(error: anyNSError(), response: nil, data: anyData()))
        XCTAssertNotNil(resultErrorFor(error: anyNSError(), response: anyHTTPURLResponse(), data: nil))
        XCTAssertNotNil(resultErrorFor(error: anyNSError(), response: anyNonHTTPURLResponse(), data: nil))
        XCTAssertNotNil(resultErrorFor(error: anyNSError(), response: anyHTTPURLResponse(), data: anyData()))
        XCTAssertNotNil(resultErrorFor(error: anyNSError(), response: anyNonHTTPURLResponse(), data: anyData()))
        XCTAssertNotNil(resultErrorFor(error: nil, response: anyNonHTTPURLResponse(), data: anyData()))
    }

    func test_get_succeedsOnDataWithValidHTTPResponse() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let result = resultValueFor(error: nil, response: response, data: data)

        XCTAssertEqual(result?.data, data)
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }

    func test_get_succeedsOnValidHTTPResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let result = resultValueFor(error: nil, response: response, data: nil)

        XCTAssertEqual(result?.data, Data())
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }

    func test_get_generateGETRequest() {
        let url = anyURL()
        URLProtocolStub.stub(error: nil)

        let expectation = XCTestExpectation(description: "Wait for completion")

        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
        }

        makeSUT().get(from: url, completion: { _ in
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 403, httpVersion: nil, headerFields: nil)!
    }

    private func anyNonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private func anyData() -> Data {
        Data("any data".utf8)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }

    private func resultErrorFor(
        error: Error? = nil,
        response: URLResponse? = nil,
        data: Data? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        URLProtocolStub.stub(error: error, response: response, data: data)

        var receivedError: Error?
        let result = resultFor(error: error, response: response, data: data, file: file, line: line)
        switch result {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("expected failure, got \(result) instead")
        }

        return receivedError
    }

    private func resultValueFor(
        error: Error? = nil,
        response: URLResponse? = nil,
        data: Data? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (response: HTTPURLResponse, data: Data)? {
        var receivedValue: (response: HTTPURLResponse, data: Data)?
        let result = resultFor(error: error, response: response, data: data, file: file, line: line)
        switch result {
        case let .success(response, data):
            receivedValue = (response, data)
        default:
            XCTFail("expected success, got \(result) instead")
        }

        return receivedValue
    }

    private func resultFor(
        error: Error? = nil,
        response: URLResponse? = nil,
        data: Data? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClientResult {
        URLProtocolStub.stub(error: error, response: response, data: data)

        var receivedResult: HTTPClientResult!
        let expectation = XCTestExpectation(description: "Wait for completion")
        makeSUT(file: file, line: line).get(from: anyURL()) { result in
            receivedResult = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)

        return receivedResult
    }
}
