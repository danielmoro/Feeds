//
//  Created by Daniel Moro on 17.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validate_deletesCacheOnRetreivalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetreival(with: anyNSError(), at: 0)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        return (sut: sut, store: store)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }
}
