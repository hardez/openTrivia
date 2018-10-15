//
//  Token.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 15.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import Foundation

struct TokenResponse: Decodable{
    let response_code: Int
    let response_message: String
    let token: String?
}
