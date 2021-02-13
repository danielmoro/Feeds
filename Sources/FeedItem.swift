//
//  Created by Daniel Moro on 13.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

struct FeedItem {
    let id: UUID // swiftlint:disable:this identifier_name
    let description: String?
    let location: String
    let imageURL: URL?
}
