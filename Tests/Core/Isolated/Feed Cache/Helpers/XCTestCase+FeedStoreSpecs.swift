//
//  Created by Daniel Moro on 22.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import FeedsCore
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetreive: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetreiveTwice: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnExistingCache(
        on sut: FeedStore,
        file _: StaticString = #file,
        line _: UInt = #line
    ) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetreive: .success(CachedFeed(feed: feed, timestamp: timestamp)))
    }

    func assertThatRetrieveHasNoSideEffectsOnExistingCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetreiveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatRetrieveDeliversFailureOnRetreivalError(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetreive: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatRetrieveTasNoSideEffectsOnRetreivalError(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetreiveTwice: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert((uniqueImageFeed().local, Date()), to: sut)

        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let firstFeed = uniqueImageFeed().local
        let firstTimetamp = Date()
        insert((firstFeed, firstTimetamp), to: sut)

        let latestFeed = uniqueImageFeed().local
        let latestTimetamp = Date()
        insert((latestFeed, latestTimetamp), to: sut)

        expect(
            sut,
            toRetreive: .success(CachedFeed(feed: latestFeed, timestamp: latestTimetamp)),
            file: file,
            line: line
        )
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert((uniqueImageFeed().local, Date()), to: sut)

        expect(sut, toRetreive: .success(.none), file: file, line: line)
    }

    func assertThatInsertFailsOnInsertionError(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected to fail with error", file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected to delete empty cache sucessfully", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        deleteCache(from: sut)

        expect(sut, toRetreive: .success(.none), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert((uniqueImageFeed().local, Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetreive: .success(.none), file: file, line: line)
    }

    func assertThatDeleteFailsOnDeletionError(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expecred delete to fail on deletion error", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnDeletionError(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        deleteCache(from: sut)

        expect(sut, toRetreive: .success(.none), file: file, line: line)
    }

    func assertThatStoreSideEffectsRunSerially(
        on sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var executedOperations: [XCTestExpectation] = []

        let op1 = expectation(description: "Operation 1")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            executedOperations.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheFeed { _ in
            executedOperations.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            executedOperations.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertEqual(
            executedOperations,
            [op1, op2, op3],
            "Expected side-effects to run serially but operations finished in the wrong order",
            file: file,
            line: line
        )
    }

    private func expect(
        _ sut: FeedStore,
        toRetreive expectedResult: FeedStore.RetreivalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = XCTestExpectation(description: "wait for retreival to complete")

        sut.retreive { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(.none), .success(.none)):
                break
            case (.failure, .failure):
                break
            case let (.success(.some(receivedCachedFeed)),
                      .success(.some(expectedCachedFeed))):
                XCTAssertEqual(receivedCachedFeed, expectedCachedFeed, file: file, line: line)
            default:
                XCTFail("Expected to receive \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func expect(
        _ sut: FeedStore,
        toRetreiveTwice expectedResult: FeedStore.RetreivalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetreive: expectedResult, file: file, line: line)
        expect(sut, toRetreive: expectedResult, file: file, line: line)
    }

    @discardableResult
    private func insert(
        _ feed: (imageFeed: [LocalFeedImage], timestamp: Date),
        to sut: FeedStore
    ) -> Error? {
        var receivedError: Error?
        let exp = XCTestExpectation(description: "wait for insertion to complete")
        sut.insert(feed: feed.imageFeed, timestamp: feed.timestamp) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                break
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedError
    }

    @discardableResult
    private func deleteCache(
        from sut: FeedStore
    ) -> Error? {
        var receivedError: Error?
        let exp = XCTestExpectation(description: "wait for deletion to complete")
        sut.deleteCacheFeed { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                break
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
}
