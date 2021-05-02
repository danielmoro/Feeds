//
//  FeedUIIntegrationTests+Localization.swift
//  Feeds_iOSTests
//
//  Created by Daniel Moro on 2.5.21..
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import Feeds_iOS
import XCTest

extension FeedUIIntegrationTests {
    func localize(
        _ key: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let bundle = Bundle(for: FeedViewController.self)
        let table = "Feeds"
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
        if localizedString == key {
            XCTFail("Missing localization for \(key)", file: file, line: line)
        }

        return localizedString
    }
}
