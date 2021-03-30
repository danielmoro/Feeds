//
//  Created by Daniel Moro on 30.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

class CoreDataFeedStoreTests: XCTestCase {
    func test_load_doesNotRetreiveItemsOnEmptyCache() throws {
        let sut = try makeSUT()

        let exp = expectation(description: "wait for load to complete")
        var receivedFeed: [FeedImage]?
        sut.load { result in
            switch result {
            case let .success(feed):
                receivedFeed = feed
            default:
                XCTFail("Expected success with empty cache, got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedFeed, [])
    }

    // MARK: - Helpers

    private func makeSUT() throws -> LocalFeedLoader {
        let url = CoreDataFeedStoreTests.testSpecificStoreURL()
    //MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedLoader {
        let url = testSpecificStoreURL()
        let store = try CoreDataFeedStore(url: url)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)

        return sut
    }

    private static func testSpecificStoreURL() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesURL.appendingPathComponent("\(type(of: self))-Store").appendingPathExtension("sqlite")
    }
}
