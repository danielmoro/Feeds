//
//  Created by Daniel Moro on 13.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
