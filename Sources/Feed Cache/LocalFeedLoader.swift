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
}

public extension LocalFeedLoader {
    typealias SaveResult = Error?

    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let deleteCacheError = error {
                completion(deleteCacheError)
            } else {
                self.cache(feed: feed, completion: completion)
            }
        }
    }

    internal func cache(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed: feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retreive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some(cacheFeed))
                where FeedCachePolicy.validate(cacheFeed.timestamp, against: self.currentDate()):
                completion(.success(cacheFeed.feed.toModel()))
            case let .failure(error):
                completion(.failure(error))
            case .success:
                completion(.success([]))
            }
        }
    }
}

public extension LocalFeedLoader {
    func validateCache() {
        store.retreive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(.none):
                break
            case let .success(.some(cacheFeed))
                where FeedCachePolicy.validate(cacheFeed.timestamp, against: self.currentDate()):
                break
            default:
                self.store.deleteCacheFeed(completion: { _ in })
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
