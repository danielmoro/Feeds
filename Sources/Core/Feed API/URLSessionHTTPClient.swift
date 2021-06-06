//
//  Created by Daniel Moro on 24.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    public init() {}

    private struct UnexpectedResponseError: Error {}
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let task: URLSessionDataTask

        func cancel() {
            task.cancel()
        }
    }

    public func get(from url: URL, completion: ((HTTPClient.Result) -> Void)? = nil) -> HTTPClientTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            completion?(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (response, data)
                } else {
                    throw UnexpectedResponseError()
                }
            })
        }

        task.resume()
        return URLSessionTaskWrapper(task: task)
    }
}
