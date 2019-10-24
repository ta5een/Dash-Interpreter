//
//  Token.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

typealias LiteralType = LiteralExprValue

enum Char {
    /// Single-character tokens
    case leftBrace, rightBrace, leftParen, rightParen, asterisk, comma, dot, minus, plus, semicolon, slash
    
    /// One or two characters literals
    case bang, bangEqual, equal, equalEqual, greater, greaterEqual, less, lessEqual
}

enum Keyword {
    case and, `class`, dbg, `else`, `false`, fun, `for`, `if`, nothing, or, `return`, `self`, `super`, then,
        `true`, `var`, `while`
}

enum Literal {
    case identifier, number, string
}

enum TokenType {
    /// Char tokens
    case char(Char)
    
    /// Keywords
    case keyword(Keyword)
    
    /// Literals
    case literal(Literal)
    
    case newline
    
    /// End of file
    case eof
    
    static func keyword(fromString string: String) -> TokenType? {
        switch string {
        case "and":     return .keyword(.and)
        case "class":   return .keyword(.class)
        case "dbg":     return .keyword(.dbg)
        case "else":    return .keyword(.else)
        case "false":   return .keyword(.false)
        case "for":     return .keyword(.for)
        case "fun":     return .keyword(.fun)
        case "if":      return .keyword(.if)
        case "nothing": return .keyword(.nothing)
        case "or":      return .keyword(.or)
        case "return":  return .keyword(.return)
        case "self":    return .keyword(.`self`)
        case "super":   return .keyword(.super)
        case "true":    return .keyword(.true)
        case "var":     return .keyword(.var)
        case "while":   return .keyword(.while)
        default:        return nil
        }
    }
}

extension TokenType: Equatable {
    static func ==(lhs: TokenType, rhs: TokenType) -> Bool {
        switch (lhs, rhs) {
        case (let .char(left), let .char(right)):
            return left == right
        case (let .keyword(left), let .keyword(right)):
            return left == right
        case (let .literal(left), let .literal(right)):
            return left == right
        case (.newline, .newline):
            return true
        case (.eof, .eof):
            return true
        default:
            return false
        }
    }
}

class Token {
    let type: TokenType
    let lexeme: String
    let literal: LiteralType?
    let line: Int
    
    init(withType type: TokenType, lexeme: String, literal: LiteralType?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        if let literal = self.literal {
            return "Token(type: \(self.type), lexeme: '\(self.lexeme)', literal: \(literal), line: \(self.line))"
        } else {
            return "Token(type: \(self.type), lexeme: '\(self.lexeme)', line: \(self.line))"
        }
    }
}
