//
//  Created by Daniel Moro on 15.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
    }

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        client.get(from: url, completion: { error in
            if error != nil {
                completion(.connectivity)
            }
        })
    }
}
