//
//  CodableFeedStoreTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 20.3.21..
//

import Feeds
import Foundation
import XCTest

class CodableFeedStore: FeedStore {
    struct Cache: Codable {
        var feed: [CaodableFeedImage]
        var date: Date

        var localFeed: [LocalFeedImage] {
            feed.map(\.local)
        }
    }

    struct CaodableFeedImage: Equatable, Codable {
        public let id: UUID // swiftlint:disable:this identifier_name
        public let description: String?
        public let location: String?
        public let url: URL

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func retreive(completion: @escaping RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        do {
            let cache = try JSONDecoder().decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.date))
        } catch {
            completion(.failure(error))
        }
    }

    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        let cache = Cache(feed: feed.map(CaodableFeedImage.init), date: timestamp)
        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func deleteCacheFeed(completion: @escaping Completion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            completion(nil)
            return
        }

        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    private func setupEmptyStoreState() {
        removeCache()
    }

    override func tearDown() {
        super.tearDown()
        undoTestSideEffects()
    }

    private func undoTestSideEffects() {
        removeCache()
    }

    private func removeCache() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toReceive: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toReceiveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnExistingCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()

        let insertionError = insert(sut, feed: feed, timestamp: timeStamp)
        XCTAssertNil(insertionError)

        expect(sut, toReceive: .found(feed: feed, timestamp: timeStamp))
    }

    func test_retrieve_hasNoSideEffectsOnExistingCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()

        let insertionError = insert(sut, feed: feed, timestamp: timeStamp)
        XCTAssertNil(insertionError)

        expect(sut, toReceiveTwice: .found(feed: feed, timestamp: timeStamp))
    }

    func test_retrieve_deliversFailureOnRetreivalError() {
        let invalidStoreURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: invalidStoreURL)

        try? "invalid data".write(to: invalidStoreURL, atomically: true, encoding: .utf8)

        expect(sut, toReceive: .failure(anyNSError()))
    }

    func test_retrieve_hasNoSideEffectsOnRetreivalError() {
        let invalidStoreURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: invalidStoreURL)

        try? "invalid data".write(to: invalidStoreURL, atomically: true, encoding: .utf8)

        expect(sut, toReceiveTwice: .failure(anyNSError()))
    }

    func test_insert_overridesCacheOnExistingCache() {
        let sut = makeSUT()
        let firstFeed = uniqueImageFeed().local
        let firstTimetamp = Date()
        let insertionError = insert(sut, feed: firstFeed, timestamp: firstTimetamp)
        XCTAssertNil(insertionError)

        let latestFeed = uniqueImageFeed().local
        let latestTimetamp = Date()
        let secondInsertionError = insert(sut, feed: latestFeed, timestamp: latestTimetamp)
        XCTAssertNil(secondInsertionError)

        expect(sut, toReceive: .found(feed: latestFeed, timestamp: latestTimetamp))
    }

    func test_insert_failsOnInsertionError() {
        let invalidStoreURL = URL(fileURLWithPath: "file://invalid-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let firstFeed = uniqueImageFeed().local
        let firstTimetamp = Date()
        let insertionError = insert(sut, feed: firstFeed, timestamp: firstTimetamp)
        XCTAssertNotNil(insertionError)
    }

    func test_delete_doesNothingOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = delete(sut)
        XCTAssertNil(deletionError)

        expect(sut, toReceive: .empty)
    }

    func test_delete_deletesCacheOnExistingCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        let insertionError = insert(sut, feed: feed, timestamp: timeStamp)
        XCTAssertNil(insertionError)

        let deletionError = delete(sut)
        XCTAssertNil(deletionError)

        expect(sut, toReceive: .empty)
    }

    func test_delete_faileOnDeletionError() {
        let nonDeletableStoreURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletableStoreURL)

        let deletionError = delete(sut)
        XCTAssertNotNil(deletionError)
    }

    func test_storeSideEffects_runSerialy() {
        let sut = makeSUT()

        var executedOperations: [XCTestExpectation] = []

        let op1 = XCTestExpectation(description: "Operation 1")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            executedOperations.append(op1)
            op1.fulfill()
        }

        let op2 = XCTestExpectation(description: "Operation 2")
        sut.deleteCacheFeed { _ in
            executedOperations.append(op2)
            op2.fulfill()
        }

        let op3 = XCTestExpectation(description: "Operation 3")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            executedOperations.append(op3)
            op3.fulfill()
        }

        wait(for: [op1, op2, op3], timeout: 5)

        XCTAssertEqual(executedOperations, [op1, op2, op3])
    }

    // MARK: Helpers

    private func cachesDirectory() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesURL
    }

    private func testSpecificStoreURL() -> URL {
        let storeURL = cachesDirectory().appendingPathComponent("\(type(of: self)).store")
        return storeURL
    }

    private func makeSUT(storeURL: URL? = nil) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackMemoryLeaks(sut)
        return sut
    }

    private func expect(
        _ sut: FeedStore,
        toReceive expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = XCTestExpectation(description: "wait for retreival to complete")

        sut.retreive { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.empty, .empty):
                break
            case (.failure, .failure):
                break
            case let (.found(feed: receivedFeed, timestamp: receivedTimestamp),
                      .found(feed: expectedFeed, timestamp: expectedTimestamp)):
                XCTAssertEqual(receivedFeed, expectedFeed)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
            default:
                XCTFail("Expected to receive \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func expect(
        _ sut: FeedStore,
        toReceiveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toReceive: expectedResult, file: file, line: line)
        expect(sut, toReceive: expectedResult, file: file, line: line)
    }

    private func insert(
        _ sut: FeedStore,
        feed: [LocalFeedImage],
        timestamp: Date
    ) -> Error? {
        var receivedError: Error?
        let exp = XCTestExpectation(description: "wait for insertion to complete")
        sut.insert(feed: feed, timestamp: timestamp) { error in
            receivedError = error
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedError
    }

    private func delete(
        _ sut: FeedStore
    ) -> Error? {
        var receivedError: Error?
        let exp = XCTestExpectation(description: "wait for deletion to complete")
        sut.deleteCacheFeed { deletionError in
            receivedError = deletionError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
}
