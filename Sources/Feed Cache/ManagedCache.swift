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

    static func findIn(context: NSManagedObjectContext) throws -> ManagedCache? {
        let fetchResult: [ManagedCache] = try context.fetch(fetchRequest())
        return fetchResult.first
    }
}
