//
//  Created by Daniel Moro on 24.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    public init() {}

    private struct UnexpectedResponseError: Error {}

    public func get(from url: URL, completion: ((HTTPClientResult) -> Void)? = nil) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion?(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion?(.success(response, data))
            } else {
                completion?(.failure(UnexpectedResponseError()))
            }
        }

        task.resume()
    }
}
