//
//  Created by Daniel Moro on 30.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import XCTest

final class FeedPresenter {
    init(view _: Any) {}
}

class FeedPresentationTests: XCTestCase {
    func test_init_doesNotPressentErrorToAnyView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        XCTAssertEqual(view.messages.isEmpty, true)
    }

    // MARK: - Helpers

    private class ViewSpy {
        var messages: [Any] = []
    }
}
