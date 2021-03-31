//
//  Created by Daniel Moro on 29.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//
//

import CoreData
import Foundation

class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID // swiftlint:disable:this identifier_name
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache?

    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }

    convenience init(feedImage: LocalFeedImage, context: NSManagedObjectContext) {
        self.init(context: context)
        id = feedImage.id
        imageDescription = feedImage.description
        location = feedImage.location
        url = feedImage.url
    }
}
