//
//  Created by Daniel Moro on 15.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: url, completion: { result in
            switch result {
            case let .success(response, data):
                completion(FeedItemsMapper.map(data: data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}
