//
//  Created by Daniel Moro on 29.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//  

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    enum Error: Swift.Error {
        case invalidModel
    }

    private var persistentContainer: NSPersistentContainer

    public init() throws {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "ManagedFeedStoreModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
                throw Error.invalidModel
            }
        persistentContainer = NSPersistentContainer(name: "ManagedFeedStoreModel", managedObjectModel: model)
    }

    public func deleteCacheFeed(completion _: @escaping Completion) {}

    public func insert(feed _: [LocalFeedImage], timestamp _: Date, completion _: @escaping Completion) {}

    public func retreive(completion: @escaping RetreivalCompletion) {
        completion(.empty)
    }
}
