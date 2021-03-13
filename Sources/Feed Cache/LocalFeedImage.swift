//
//  Created by Daniel Moro on 13.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public init(
        id: UUID, // swiftlint:disable:this identifier_name
        description: String?,
        location: String?,
        imageURL: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        url = imageURL
    }

    public let id: UUID // swiftlint:disable:this identifier_name
    public let description: String?
    public let location: String?
    public let url: URL
}
