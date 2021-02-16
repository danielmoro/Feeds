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
            case let .success(response, data):
                do {
                    let items = try FeedItemsMapper.map(response: response, data: data)
                    return completion(.success(items))
                } catch let error as Error {
                    return completion(.failure(error))
                } catch {
                    return completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}

private class FeedItemsMapper {
    private struct Root: Decodable {
        var images: [Item]
    }

    private struct Item: Decodable {
        private let id: UUID // swiftlint:disable:this identifier_name
        private let description: String?
        private let location: String?
        private let image: URL

        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }

        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.images.map(\.item)
    }
}
