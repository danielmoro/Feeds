//
//  UIImage+TestHelpers.swift
//  Feeds_iOSTests
//
//  Created by Daniel Moro on 2.5.21..
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

extension UIImage {
    static func make(withColor color: CGColor) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
