//
//  Created by Daniel Moro on 29.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import CoreData
import Foundation

public class CoreDataFeedStore: FeedStore {
    enum Error: Swift.Error {
        case invalidModel
        case loadFailed(Swift.Error)
    }

    private var persistentContainer: NSPersistentContainer
    private var backgroundContext: NSManagedObjectContext

    public init(url: URL) throws {
        persistentContainer = try CoreDataFeedStore.loadPersistentContainerWith(url: url)
        backgroundContext = persistentContainer.newBackgroundContext()
    }

    public func deleteCacheFeed(completion _: @escaping Completion) {}

    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        backgroundContext.perform {
            do {
                try ManagedCache.deleteIn(context: self.backgroundContext)

                let cache = ManagedCache(context: self.backgroundContext)
                cache.timestamp = timestamp
                cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage(feedImage: $0, context: self.backgroundContext) })

                try self.backgroundContext.save()
                completion(nil)
            } catch {}
        }
    }

    public func retreive(completion: @escaping RetreivalCompletion) {
        backgroundContext.perform {
            do {
                if let cache = try ManagedCache.findIn(context: self.backgroundContext) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {}
        }
    }

    private static func makeContainer() throws -> NSPersistentContainer {
        guard let modelURL = Bundle(for: self).url(forResource: "ManagedFeedStoreModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            throw Error.invalidModel
        }

        return NSPersistentContainer(name: "ManagedFeedStoreModel", managedObjectModel: model)
    }

    private static func loadPersistentContainerWith(url: URL) throws -> NSPersistentContainer {
        let persistentContainer = try makeContainer()
        persistentContainer.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        var loadError: Swift.Error?
        persistentContainer.loadPersistentStores { _, error in
            loadError = error
        }

        if let loadError = loadError {
            throw Error.loadFailed(loadError)
        }

        return persistentContainer
    }
}
