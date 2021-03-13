//
//  Created by Daniel Moro on 16.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID // swiftlint:disable:this identifier_name
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal enum FeedItemsMapper {
    private struct Root: Decodable {
        var images: [RemoteFeedItem]
    }

    private static let OK_200 = 200 // swiftlint:disable:this identifier_name

    internal static func map(data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }

        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.images
        } catch {
            throw RemoteFeedLoader.Error.invalidData
        }
    }
}
