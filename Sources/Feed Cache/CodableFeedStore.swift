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
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }

            do {
                let cache = try JSONDecoder().decode(Cache.self, from: data)
                completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.date)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            let cache = Cache(feed: feed.map(CaodableFeedImage.init), date: timestamp)
            do {
                let data = try JSONEncoder().encode(cache)
                try data.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func deleteCacheFeed(completion: @escaping Completion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                completion(.success(()))
                return
            }

            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
