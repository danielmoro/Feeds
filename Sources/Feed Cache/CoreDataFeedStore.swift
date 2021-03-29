//
//  Created by Daniel Moro on 29.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//  

import Foundation

public class CoreDataFeedStore: FeedStore {
    public init() {}

    public func deleteCacheFeed(completion _: @escaping Completion) {}

    public func insert(feed _: [LocalFeedImage], timestamp _: Date, completion _: @escaping Completion) {}

    public func retreive(completion: @escaping RetreivalCompletion) {
        completion(.empty)
    }
}
