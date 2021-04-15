//
//  Created by Daniel Moro on 15.4.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let cellIdentifier = String(describing: T.self)
        let cell = dequeueReusableCell(withIdentifier: cellIdentifier)
        return cell as! T
    }
}
