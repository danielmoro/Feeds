//
//  Created by Daniel Moro on 17.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import Foundation

func anyURL() -> URL {
    URL(string: "http://a-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 1)
}
