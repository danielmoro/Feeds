//
//  Created by Daniel Moro on 30.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds
import XCTest

class CoreDataFeedStoreTests: XCTestCase {
    func test_load_doesNotRetreiveItemsOnEmptyCache() throws {
        let sut = try makeSUT()

        expect(sut, toLoad: [])
    }

    func test_loadReturnsImagesSavedByAnotherStore() throws {
        let sutToSave = try makeSUT()
        let sutToLoad = try makeSUT()
        let anyFeed = uniqueImageFeed().models

        let saveExp = expectation(description: "Wait for save to complete")
        sutToSave.save(anyFeed) { result in
            XCTAssertNil(result, "Expected not to receive anything, got \(String(describing: result)) instead")

            saveExp.fulfill()
        }

        wait(for: [saveExp], timeout: 1.0)

        expect(sutToLoad, toLoad: anyFeed)
    }

    override func setUp() {
        super.setUp()

        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoTestSideEffects()
    }

    private func setupEmptyStoreState() {
        cleanupCache()
    }

    private func undoTestSideEffects() {
        cleanupCache()
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedLoader {
        let url = testSpecificStoreURL()
        let store = try CoreDataFeedStore(url: url)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)

        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

        return sut
    }

    private func testSpecificStoreURL() -> URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesURL
            .appendingPathComponent("\(type(of: self))-Store")
            .appendingPathExtension("sqlite")
    }

    private func cleanupCache() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    private func expect(
        _ sut: LocalFeedLoader,
        toLoad expectedFeed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let loadExp = expectation(description: "wait for load to complete")
        var receivedFeed: [FeedImage]?
        sut.load { result in
            switch result {
            case let .success(feed):
                receivedFeed = feed
            default:
                XCTFail("Expected success with empty cache, got \(result) instead", file: file, line: line)
            }
            loadExp.fulfill()
        }

        wait(for: [loadExp], timeout: 1.0)
        XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
    }
}
