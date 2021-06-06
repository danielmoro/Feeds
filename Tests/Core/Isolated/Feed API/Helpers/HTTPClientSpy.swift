//
//  Created by Daniel Moro on 6.6.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import Foundation

class HTTPClientSpy: HTTPClient {
    var messages: [(url: URL, completion: ((HTTPClient.Result) -> Void)?)] = []

    var requestedURLs: [URL] {
        messages.map(\.url)
    }

    func get(from url: URL, completion: ((HTTPClient.Result) -> Void)?) {
        messages.append((url, completion))
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
