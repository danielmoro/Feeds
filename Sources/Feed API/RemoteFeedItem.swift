//
//  Created by Daniel Moro on 13.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID // swiftlint:disable:this identifier_name
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
