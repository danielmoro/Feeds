//
//  Created by Daniel Moro on 31.3.21.
//  Copyright © 2021 Daniel Moro. All rights reserved.
//

import UIKit

struct FeedImageViewModel {
    var description: String?
    var location: String?
    var imageName: String
}

class FeedViewController: UITableViewController {
    let feed: [FeedImageViewModel] = FeedImageViewModel.prototypeFeed

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell // swiftlint:disable:this force_cast
        cell.configure(with: feed[indexPath.row])
        return cell
    }
}

extension FeedImageCell {
    func configure(with model: FeedImageViewModel) {
        descriptionLabel?.text = model.description
        locationContainer?.isHidden = model.location == nil
        imageContentView?.image = UIImage(named: model.imageName)
        locationLabel?.text = model.location
    }
}
