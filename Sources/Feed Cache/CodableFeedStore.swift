//
//  CodableFeedStore.swift
//  Feeds
//
//  Created by Daniel Moro on 21.3.21..
//

import Foundation

public class CodableFeedStore: FeedStore {
    struct Cache: Codable {
        var feed: [CaodableFeedImage]
        var date: Date

        var localFeed: [LocalFeedImage] {
            feed.map(\.local)
        }
    }

    struct CaodableFeedImage: Equatable, Codable {
        public let id: UUID // swiftlint:disable:this identifier_name
        public let description: String?
        public let location: String?
        public let url: URL

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let storeURL: URL
    private lazy var queue: DispatchQueue = {
        DispatchQueue(label: "\(type(of: self))-Queue", attributes: .concurrent)
    }()

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retreive(completion: @escaping RetreivalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            completion(Result {
                guard let data = try? Data(contentsOf: storeURL) else {
                    return .none
                }

                let cache = try JSONDecoder().decode(Cache.self, from: data)
                return CachedFeed(feed: cache.localFeed, timestamp: cache.date)
            })
        }
    }

    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            completion(Result {
                let cache = Cache(feed: feed.map(CaodableFeedImage.init), date: timestamp)
                let data = try JSONEncoder().encode(cache)
                try data.write(to: storeURL)
                return
            })
        }
    }

    public func deleteCacheFeed(completion: @escaping Completion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            completion(Result {
                guard FileManager.default.fileExists(atPath: storeURL.path) else {
                    return
                }

                try FileManager.default.removeItem(at: storeURL)
                return
            })
        }
    }
}
