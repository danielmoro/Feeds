//
//  Created by Daniel Moro on 29.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//
//

import CoreData
import Foundation

class ManagedCache: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }

    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet?

    var localFeed: [LocalFeedImage] {
        if let array = feed?.array as? [ManagedFeedImage] {
            return array.map(\.local)
        } else {
            return []
        }
    }

    static func make(feed: [LocalFeedImage], timestamp: Date, in context: NSManagedObjectContext) {
        let cache = ManagedCache(context: context)
        cache.timestamp = timestamp
        cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage(feedImage: $0, context: context) })
    }

    static func findIn(context: NSManagedObjectContext) throws -> ManagedCache? {
        let fetchResult: [ManagedCache] = try context.fetch(fetchRequest())
        return fetchResult.first
    }

    static func deleteIn(context: NSManagedObjectContext) throws {
        if let found = try findIn(context: context) {
            context.delete(found)
        }
    }
}
