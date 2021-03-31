//
//  Created by Daniel Moro on 31.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath)
    }
}
