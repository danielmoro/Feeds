//
//  Created by Daniel Moro on 10.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public struct CachedFeed: Equatable {
    var feed: [LocalFeedImage]
    var timestamp: Date

    public init(feed: [LocalFeedImage], timestamp: Date) {
        self.feed = feed
        self.timestamp = timestamp
    }
}

public protocol FeedStore {
    typealias CompletionResult = Result<Void, Error>
    typealias Completion = (CompletionResult) -> Void
    typealias RetreivalResult = Result<CachedFeed?, Error>
    typealias RetreivalCompletion = (RetreivalResult) -> Void

    func deleteCacheFeed(completion: @escaping Completion)
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion)
    func retreive(completion: @escaping RetreivalCompletion)
}
