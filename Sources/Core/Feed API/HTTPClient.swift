//
//  Created by Daniel Moro on 16.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(HTTPURLResponse, Data), Error>
    @discardableResult
    func get(from url: URL, completion: ((Result) -> Void)?) -> HTTPClientTask
}
