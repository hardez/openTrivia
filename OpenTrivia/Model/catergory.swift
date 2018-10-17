//
//  catergory.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 17.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import Foundation

struct TriviaCategories: Decodable{
    let trivia_categories: [TriviaCategorie]
}

struct TriviaCategorie: Decodable{
    let id: Int
    let name: String
}
