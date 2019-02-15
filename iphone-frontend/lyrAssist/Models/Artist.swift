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
    var id: Int?
    var name: String
    var urlName: String
    var url: String?
    var avatarURL: String?
    var avatarImage: UIImage?
    var song: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, song, urlName
        case avatarURL = "avatar"
    }
}

struct ArtistListResponse: Codable {
    var statusCode: Int
    var data: [Artist]
}
