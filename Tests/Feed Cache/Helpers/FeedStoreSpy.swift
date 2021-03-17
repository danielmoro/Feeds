//
//  FeedStoreSpy.swift
//  FeedsTests
//
//  Created by Daniel Moro on 13.3.21..
//

import Feeds
import Foundation

internal class FeedStoreSpy: FeedStore {
    private var deletionCompletions: [Completion] = []
    private var insertionCompletions: [Completion] = []
    private var retreivalCompletions: [RetreivalCompletion] = []

    internal enum ReceivedMessage: Equatable {
        case insert(feed: [LocalFeedImage], timestamp: Date)
        case delete
        case retrieve
    }

    internal var receivedMessages: [ReceivedMessage] = []

    func deleteCacheFeed(completion: @escaping Completion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.delete)
    }

    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed: feed, timestamp: timestamp))
    }

    func retreive(completion: @escaping RetreivalCompletion) {
        retreivalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }

    internal func completeDeletion(with error: Error, at index: Int) {
        deletionCompletions[index](error)
    }

    internal func completeDeletionSuccesfully(at index: Int) {
        deletionCompletions[index](nil)
    }

    internal func completeInsertion(with _: [FeedImage], at index: Int) {
        insertionCompletions[index](nil)
    }

    internal func completeInsertion(with error: Error, at index: Int) {
        insertionCompletions[index](error)
    }

    internal func completeRetreival(with error: Error, at index: Int) {
        retreivalCompletions[index](.failure(error))
    }

    internal func completeRetreivalWithEmptyCache(at index: Int) {
        retreivalCompletions[index](.empty)
    }

    internal func completeRetreival(with feed: [LocalFeedImage], timestamp: Date, at index: Int) {
        retreivalCompletions[index](.found(feed: feed, timestamp: timestamp))
    }
}