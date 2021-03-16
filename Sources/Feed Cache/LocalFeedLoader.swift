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

    private var caledar = Calendar(identifier: .gregorian)

    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let deleteCacheError = error {
                completion(deleteCacheError)
            } else {
                self.cache(feed: feed, completion: completion)
            }
        }
    }

    public func cache(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed: feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retreive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .found(feed: feed, timestamp: timestamp) where self.validate(timestamp):
                completion(.success(feed.toModel()))
            case .empty:
                completion(.success([]))
            case .found:
                self.store.deleteCacheFeed(completion: { _ in })
                completion(.success([]))
            case let .failure(error):
                self.store.deleteCacheFeed(completion: { _ in })
                completion(.failure(error))
            }
        }
    }

    private var maxCacheAgeInDays: Int {
        7
    }

    private func validate(_ timestamp: Date) -> Bool {
        if let maxCacheAge = caledar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) {
            return maxCacheAge > currentDate()
        } else {
            return false
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
