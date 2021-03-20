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
        var feed: [LocalFeedImage]
        var date: Date
    }

    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
        do {
            let data = try Data(contentsOf: storeURL)
            let cache = try JSONDecoder().decode(Cache.self, from: data)
            completion(.found(feed: cache.feed, timestamp: cache.date))
        } catch {
            completion(.empty)
        }
    }

    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.Completion) {
        let cache = Cache(feed: feed, date: timestamp)
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
    override class func tearDown() {
        super.tearDown()

        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        let exp = XCTestExpectation(description: "wait for retreival to complete")
        sut.retreive { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected to receive empty result, got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        let exp = XCTestExpectation(description: "wait for retreival to complete")
        sut.retreive { firstResult in
            sut.retreive { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrievingAfterInsert_deliversFeedInserted() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()

        let exp = XCTestExpectation(description: "wait for retreival to complete")
        sut.insert(feed: feed, timestamp: timeStamp) { error in
            XCTAssertNil(error)

            sut.retreive { result in
                switch result {
                case let .found(feed: receivedFeed, timestamp: receivedTimestamp):
                    XCTAssertEqual(receivedFeed, feed)
                    XCTAssertEqual(receivedTimestamp, timeStamp)
                default:
                    XCTFail("Expected to receive inserted feed, got \(result) instead")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: Helpers

    private static func testSpecificStoreURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let storeURL = documentsURL.appendingPathComponent("\(type(of: self)).store")
        return storeURL
    }

    private func makeSUT() -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: CodableFeedStoreTests.testSpecificStoreURL())
        trackMemoryLeaks(sut)
        return sut
    }
}