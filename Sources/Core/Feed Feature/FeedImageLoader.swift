//
//  Created by Daniel Moro on 10.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

public protocol FeedImageLoadTask {
    func cancel()
}

public protocol FeedImageLoader {
    typealias FeedImageResult = Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (FeedImageResult) -> Void) -> FeedImageLoadTask
}
