//
//  Created by Daniel Moro on 13.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable {
    public init(
        id: UUID, // swiftlint:disable:this identifier_name
        description: String?,
        location: String?,
        imageURL: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }

    public let id: UUID // swiftlint:disable:this identifier_name
    public let description: String?
    public let location: String?
    public let imageURL: URL
}

extension FeedItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case id // swiftlint:disable:this identifier_name
        case description
        case location
        case imageURL = "image"
    }
}
