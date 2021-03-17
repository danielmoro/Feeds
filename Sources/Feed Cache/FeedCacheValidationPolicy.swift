//
//  Created by Daniel Moro on 17.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

final class FeedCacheValidationPolicy {
    private static var caledar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int {
        7
    }

    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        if let maxCacheAge = caledar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) {
            return maxCacheAge > date
        } else {
            return false
        }
    }
}
