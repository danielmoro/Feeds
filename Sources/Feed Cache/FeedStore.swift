//
//  Created by Daniel Moro on 10.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias Completion = (Error?) -> Void
    typealias RetreivalCompletion = (RetrieveCachedFeedResult) -> Void

    func deleteCacheFeed(completion: @escaping Completion)
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion)
    func retreive(completion: @escaping RetreivalCompletion)
}
