//
//  Question.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 14.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import Foundation

enum Difficulty:String, Decodable{
    case easy, medium, hard
}

enum Type:String, Decodable{
    case multiple, boolean
}

struct Question: Decodable{
    let category: String
    let type: Type
    let difficulty: Difficulty
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    func getAnswers() -> [String]{
        var answers:[String] = self.incorrect_answers
        answers.append(correct_answer)
        
        return answers
    }
    
    func cleanup(){
        
    }
}

struct Response: Decodable{
    let response_code: Int
    let results: [Question]
}

extension String {
    func htmlDecoded()->String {
        
        guard (self != "") else { return self }
        
        var newStr = self
        // from https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
        let entities = [ //a dictionary of HTM/XML entities.
            "&quot;"    : "\"",
            "&amp;"     : "&",
            "&apos;"    : "'",
            "&lt;"      : "<",
            "&gt;"      : ">",
            "&deg;"     : "º",
            "&#039;"    : "'",
            ]
        
        for (name,value) in entities {
            newStr = newStr.replacingOccurrences(of: name, with: value)
        }
        return newStr
    }
}
