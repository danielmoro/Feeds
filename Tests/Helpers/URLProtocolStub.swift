//
//  Created by Daniel Moro on 23.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private static var stubs: [URL: Stub] = [:]
    private static var onRequest: ((URLRequest) -> Void)?

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

    static func handleRequest(_ request: @escaping ((URLRequest) -> Void)) {
        onRequest = request
    }

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }

        onRequest?(request)
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
