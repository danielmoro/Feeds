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
            completion(Result {
                try ManagedCache.deleteIn(context: context)
                try context.save()
            })
        }
    }

    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        perform { context in
            completion(Result {
                try ManagedCache.deleteIn(context: context)
                ManagedCache.make(feed: feed, timestamp: timestamp, in: context)
                try context.save()
            })
        }
    }

    public func retreive(completion: @escaping RetreivalCompletion) {
        perform { context in
            completion(Result {
                if let cache = try ManagedCache.findIn(context: context) {
                    return CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
                } else {
                    return nil
                }
            })
        }
    }

    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        backgroundContext.perform {
            action(context)
        }
    }

    private static var cachedModel: NSManagedObjectModel?

    private static func makeModel() throws -> NSManagedObjectModel {
        if let cachedModel = cachedModel {
            return cachedModel
        }

        guard let modelURL = Bundle(for: self).url(forResource: "ManagedFeedStoreModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            throw Error.invalidModel
        }

        cachedModel = model
        return model
    }

    private static func makeContainer() throws -> NSPersistentContainer {
        let model = try makeModel()
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
