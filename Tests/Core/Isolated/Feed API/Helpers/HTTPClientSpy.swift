//
//  Created by Daniel Moro on 6.6.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import Foundation

class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        func cancel() {}
    }

    var messages: [(url: URL, completion: ((HTTPClient.Result) -> Void)?)] = []

    var requestedURLs: [URL] {
        messages.map(\.url)
    }

    @discardableResult
    func get(from url: URL, completion: ((HTTPClient.Result) -> Void)?) -> HTTPClientTask {
        messages.append((url, completion))

        return Task()
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion?(.failure(error))
    }

    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: messages[index].url,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion?(.success((response, data)))
    }
}
