//
//  Created by Daniel Moro on 10.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    var store: FeedStore
    var currentDate: () -> Date

    public typealias SaveResult = Error?

    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let deleteCacheError = error {
                completion(deleteCacheError)
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }

    public func cache(items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.insert(items: items.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
