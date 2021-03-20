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
    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()

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
        let sut = CodableFeedStore()

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
}
