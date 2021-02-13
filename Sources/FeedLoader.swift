//
//  Created by Daniel Moro on 13.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
