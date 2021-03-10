//
//  Created by Daniel Moro on 10.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias Completion = (Error?) -> Void

    func deleteCacheFeed(completion: @escaping Completion)
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping Completion)
}

public final class LocalFeedLoader {
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    var store: FeedStore
    var currentDate: () -> Date

    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let deleteCacheError = error {
                completion(deleteCacheError)
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }

    public func cache(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.insert(items: items, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}
