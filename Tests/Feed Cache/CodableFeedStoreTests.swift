//
//  CodableFeedStoreTests.swift
//  FeedsTests
//
//  Created by Daniel Moro on 20.3.21..
//

import Feeds
import Foundation
import XCTest

class CodableFeedStore {
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

    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
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

    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.Completion) {
        let cache = Cache(feed: feed.map(CaodableFeedImage.init), date: timestamp)
        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: storeURL)
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

    // MARK: Helpers

    private func testSpecificStoreURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let storeURL = documentsURL.appendingPathComponent("\(type(of: self)).store")
        return storeURL
    }

    private func makeSUT(storeURL: URL? = nil) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackMemoryLeaks(sut)
        return sut
    }

    private func expect(
        _ sut: CodableFeedStore,
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
        _ sut: CodableFeedStore,
        toReceiveTwice expectedResult: RetrieveCachedFeedResult,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) {
        expect(sut, toReceive: expectedResult)
        expect(sut, toReceive: expectedResult)
    }

    private func insert(
        _ sut: CodableFeedStore,
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
}
