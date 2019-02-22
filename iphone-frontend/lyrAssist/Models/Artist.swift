//
//  Artist.swift
//  lyrAssist
//
//  Created by Austin McInnis on 2/14/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//
import UIKit
import Foundation

struct Artist: Codable {
    var id: String
    var name: String
    var url: String?
    var avatarURL: String?
    var avatarImage: UIImage?
    var song: String?
    
    enum CodingKeys: String, CodingKey {
        case name, url, song
        case id = "artist_id"
        case avatarURL = "avatar"
    }
}

struct ArtistListResponse: Codable {
    var statusCode: Int
    var data: [Artist]
}
