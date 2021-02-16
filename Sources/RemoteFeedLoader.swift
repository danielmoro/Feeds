//
//  Created by Daniel Moro on 15.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

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
            case let .success(_, data):
                do {
                    let root = try JSONDecoder().decode(Root.self, from: data)
                    completion(.success(root.images ?? []))
                } catch {
                    print(error)
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}

struct Root: Decodable {
    var images: [FeedItem]?
}
