//
//  Created by Daniel Moro on 15.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    typealias Result = LoadFeedResult

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (LoadFeedResult) -> Void = { _ in }) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(response, data):
                completion(FeedItemsMapper.map(data: data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
}
