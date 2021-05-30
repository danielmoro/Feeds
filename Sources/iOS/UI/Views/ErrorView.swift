//
//  Created by Daniel Moro on 30.5.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet
    private var titleLabel: UILabel?

    public var message: String? {
        get {
            titleLabel?.text
        }

        set {
            titleLabel?.text = newValue
        }
    }
}
