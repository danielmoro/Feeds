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
            if newValue == nil {
                hideMessage()
            } else {
                showMesage()
            }
        }
    }

    private func showMesage() {
        guard titleLabel?.alpha == 0 else {
            return
        }

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.titleLabel?.alpha = 1
        }
    }

    @IBAction
    private func hideMessage() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.titleLabel?.alpha = 0
        }
    }
}
