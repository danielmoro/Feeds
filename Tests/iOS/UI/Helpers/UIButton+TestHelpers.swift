//
//  UIButton+TestHelpers.swift
//  Feeds_iOSTests
//
//  Created by Daniel Moro on 2.5.21..
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
