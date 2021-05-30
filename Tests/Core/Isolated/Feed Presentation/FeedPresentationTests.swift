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
        let (_, view) = makeSUT()
        XCTAssertEqual(view.messages.isEmpty, true)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackMemoryLeaks(view, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    private class ViewSpy {
        var messages: [Any] = []
    }
}
