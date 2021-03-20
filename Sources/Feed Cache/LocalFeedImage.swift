//
//  Created by Daniel Moro on 13.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
    public init(
        id: UUID, // swiftlint:disable:this identifier_name
        description: String?,
        location: String?,
        url: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }

    public let id: UUID // swiftlint:disable:this identifier_name
    public let description: String?
    public let location: String?
    public let url: URL
}
