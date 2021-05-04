//
//  Created by Daniel Moro on 4.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import Foundation

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageLoader where T == FeedImageLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageResult) -> Void) -> FeedImageLoadTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
