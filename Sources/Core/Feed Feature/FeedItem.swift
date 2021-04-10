//
//  Created by Daniel Moro on 13.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public struct FeedImage: Equatable {
    public init(
        id: UUID,
        description: String?,
        location: String?,
        url: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }

    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
}
