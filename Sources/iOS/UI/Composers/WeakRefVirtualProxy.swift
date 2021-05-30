//
//  Created by Daniel Moro on 4.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Foundation

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView {
    func display(_ model: FeedImageModel<T.Image>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(error: String) {
        object?.display(error: error)
    }
}
