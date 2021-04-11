//
//  Created by Daniel Moro on 11.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader

    var onRefresh: Observer<[FeedImage]>?
    var onLoadingChange: Observer<Bool>?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        onLoadingChange?(true)
        feedLoader.load(completion: { [weak self] result in
            if let newResult = try? result.get() {
                self?.onRefresh?(newResult)
            }

            self?.onLoadingChange?(false)
        })
    }
}
