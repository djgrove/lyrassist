//
//  lyrAssistError.swift
//  lyrAssist
//
//  Created by Austin McInnis on 2/22/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import Foundation

enum LAError: Error {
    case ParseError(subject: String, artist: String)
}
