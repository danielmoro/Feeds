//
//  Created by Daniel Moro on 23.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?

    private struct Stub {
        var error: Error?
        var data: Data?
        var response: URLResponse?
    }

    static func stub(error: Error? = nil, response: URLResponse? = nil, data: Data? = nil) {
        stub = Stub(error: error, data: data, response: response)
    }

    static func startInterceptingURLRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopInterceptingURLRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        requestObserver = nil
    }

    static func observeRequest(_ observer: @escaping ((URLRequest) -> Void)) {
        requestObserver = observer
    }

    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let stub = URLProtocolStub.stub else {
            return
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
