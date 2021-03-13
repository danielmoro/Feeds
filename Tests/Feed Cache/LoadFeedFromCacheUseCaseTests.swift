//
//  LoadFeedFromCacheUseCaseTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 13.3.21..
//

import Feeds
import XCTest

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestsCacheRetreivalFromTheStore() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetreivalError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()

        var receivedError: Error?
        let exp = XCTestExpectation(description: "wait fro retreival completion")
        sut.load { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeRetreival(with: expectedError, at: 0)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError)
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
