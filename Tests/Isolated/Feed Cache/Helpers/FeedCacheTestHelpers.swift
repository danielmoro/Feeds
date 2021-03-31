//
//  Created by Daniel Moro on 17.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import Foundation

extension Date {
    private var feedCacheMaxAgeInDays: Int {
        7
    }

    func minusFeedCacheMaxAge() -> Date {
        adding(days: -feedCacheMaxAgeInDays)
    }

    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        addingTimeInterval(seconds)
    }
}
