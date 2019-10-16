//
//  Token.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

typealias Literal = Any

enum TokenType {
    /// Single-character tokens
    case leftBrace, rightBrace, leftParen, rightParen, asterisk, comma, dot, minus, plus, semicolon, slash
    
    /// One or two characters literals
    case bang, bangEqual, equal, equalEqual, greater, greaterEqual, less, lessEqual
    
    /// Keywords
    case and, `class`, `else`, `false`, fun, `for`, `if`, nothing, or, print, `return`, `self`, `super`,
        `true`, `var`, `while`
    
    /// Literals
    case identifier, number, string
    
    /// End of file
    case eof
}

class Token {
    
    let type: TokenType
    let lexeme: String
    let literal: Literal?
    let line: Int
    
    init(withType type: TokenType, lexeme: String, literal: Literal?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
    
}

extension Token: CustomStringConvertible {
    
    var description: String { "Token(type: \(self.type), lexeme: '\(self.lexeme)', literal: '\(self.literal ?? "<no-literal>")')" }
    
}
