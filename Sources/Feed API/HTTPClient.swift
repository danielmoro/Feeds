//
//  Created by Daniel Moro on 16.2.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
