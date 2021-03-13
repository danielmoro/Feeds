//
//  Created by Daniel Moro on 10.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias Completion = (Error?) -> Void

    func deleteCacheFeed(completion: @escaping Completion)
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion)
    func retreive()
}
