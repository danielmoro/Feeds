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

    public func deleteCacheFeed(completion: @escaping Completion) {
        perform { context in
            do {
                try ManagedCache.deleteIn(context: context)

                try context.save()
                completion(nil)

            } catch {
                completion(error)
            }
        }
    }

    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        perform { context in
            do {
                try ManagedCache.deleteIn(context: context)

                let cache = ManagedCache(context: context)
                cache.timestamp = timestamp
                cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage(feedImage: $0, context: context) })

                try context.save()
                completion(nil)

            } catch {
                completion(error)
            }
        }
    }

    public func retreive(completion: @escaping RetreivalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.findIn(context: context) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        backgroundContext.perform {
            action(context)
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
