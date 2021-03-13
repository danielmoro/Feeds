//
//  RemoteFeedItem.swift
//  Feeds
//
//  Created by Daniel Moro on 13.3.21..
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID // swiftlint:disable:this identifier_name
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
