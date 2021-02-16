//
//  Created by Daniel Moro on 16.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

internal enum FeedItemsMapper {
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

    private static let OK_200 = 200 // swiftlint:disable:this identifier_name

    internal static func map(data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200 else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            let items = root.images.map(\.item)
            return .success(items)
        } catch {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
    }
}
