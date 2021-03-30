//
//  Created by Daniel Moro on 16.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(HTTPURLResponse, Data), Error>
    func get(from url: URL, completion: ((Result) -> Void)?)
}
