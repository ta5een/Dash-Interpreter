//
//  Scanner.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class Scanner {
    private let source: String
    private var tokens: [Token] = []
    
    private var start: Int = 0
    private var current: Int = 0
    private var column: Int = 1
    private var line: Int = 1
    
    private var isAtEnd: Bool {
        get { self.current >= source.count }
    }
    
    init(fromSource source: String) {
        self.source = source
    }
    
    func scanTokens() -> [Token] {
        while (!self.isAtEnd) {
            self.start = self.current
            self.scan()
        }
        
        // self.tokens.append(Token(withType: .eof, lexeme: "", literal: nil, line: self.line))
        self.addToken(type: .eof, lexeme: "", literal: nil)
        return self.tokens
    }
    
    func scan() {
        switch self.advance() {
        case "(":   self.addToken(type: .char(.leftParen))
        case ")":   self.addToken(type: .char(.rightParen))
        case "{":   self.addToken(type: .char(.leftBrace))
        case "}":   self.addToken(type: .char(.rightParen))
        
        case "*":   self.addToken(type: .char(.asterisk))
        case ",":   self.addToken(type: .char(.comma))
        case ".":   self.addToken(type: .char(.dot))
        case "-":   self.addToken(type: .char(.minus))
        case "+":   self.addToken(type: .char(.plus))
        case ";":   self.addToken(type: .char(.semicolon))
        case "/":   self.addToken(type: .char(.slash))
            
        case "!":   self.addToken(type: (self.nextTokenMatches("=") ? .char(.bangEqual) : .char(.bang)))
        case "=":   self.addToken(type: (self.nextTokenMatches("=") ? .char(.equalEqual) : .char(.equal)))
        case "<":   self.addToken(type: (self.nextTokenMatches("=") ? .char(.lessEqual) : .char(.less)))
        case ">":   self.addToken(type: (self.nextTokenMatches("=") ? .char(.greaterEqual) : .char(.greater)))
            
        case "#":   while self.peek() != "\n" && !self.isAtEnd { self.advance() }
        
        case "\n":  self.newLine()
        case "", " ", "\r", "\t": break
            
        case "\"":  self.string(fromIndex: self.current - 1, symbol: "\"")
        case "'":   self.string(fromIndex: self.current - 1, symbol: "'")
        case let n where n.rangeOfCharacter(from: .decimalDigits) != nil: self.number(fromIndex: self.current - 1)
        case let a where (a.rangeOfCharacter(from: .alphanumerics) != nil) || a == "_": self.identifier(fromIndex: self.current - 1)
        
        case let char:
            Dash.reportError(location: ErrorLocation(line: self.line, column: self.column),
                             message: "Unexpected character `\(char)`.",
                             help: "The symbol `\(char)` isn't recognised. Was this meant to be here?")
        }
    }
    
    func addToken(type: TokenType, lexeme: String? = nil, literal: LiteralType? = nil) {
        self.tokens.append(Token(withType: type,
                                 lexeme: lexeme ?? self.source[self.start ..< self.current],
                                 literal: literal,
                                 line: self.line))
    }
}

// MARK: - Matching
extension Scanner {
    func nextTokenMatches(_ expected: String) -> Bool {
        if self.isAtEnd { return false }
        if self.source[self.current] != expected { return false }
        
        self.current += 1
        self.column += 1
        return true
    }
    
    // FIXME: Perhaps find a way to to return a `Character` instead?
    @discardableResult
    func advance() -> String {
        self.current += 1
        self.column += 1
        return self.source[self.current - 1]
    }
    
    func peek() -> String {
        if self.isAtEnd { return "\0" }
        return self.source[self.current]
    }
    
    func peekNext() -> String {
        if ((self.current + 1) >= self.source.count) { return "\0" }
        return self.source[self.current + 1]
    }
}

// MARK: - Literals
extension Scanner {
    func newLine() {
        // self.addToken(type: .newline, lexeme: "\\n", literal: "\\n")
        self.line += 1
        self.column = 1
    }
    
    func string(fromIndex index: Int, symbol: String) {
        while self.peek() != symbol && !self.isAtEnd {
            if (self.peek() == "\n") {
                self.line += 1
                self.column = 1
            }
            
            self.advance()
        }
        
        if self.isAtEnd {
            Dash.reportError(location: ErrorLocation(line: self.line, column: self.column),
                             message: "Unterminated string.",
                             help: "There seems to be a missing `\(symbol)` on this line. Add the missing quotation mark to correctly close it.")
            return
        }
        
        // Capture the closing `"`
        self.advance()
        
        // Trim the surrounding quotes and add token
        self.addToken(type: .literal(.string), literal: self.source[(self.start + 1) ..< self.current - 1])
    }
    
    func number(fromIndex index: Int) {
        func peekAndAdvance() {
            while self.peek().rangeOfCharacter(from: .decimalDigits) != nil {
                self.advance()
            }
        }
        
        peekAndAdvance()
        
        // Look for fractional part
        if self.peek() == "." && (self.peekNext().rangeOfCharacter(from: .decimalDigits) != nil) {
            self.advance()
            peekAndAdvance()
        }
        
        self.addToken(type: .literal(.number), literal: Double(self.source[self.start ..< self.current]))
    }
    
    func identifier(fromIndex index: Int) {
        while (self.peek().rangeOfCharacter(from: .alphanumerics) != nil) || self.peek() == "_" {
            self.advance()
        }
        
        // See if identifier is reserved word
        let text = self.source[self.start ..< self.current]
        if let type = TokenType.keyword(fromString: text) {
            self.addToken(type: type)
        } else {
            self.addToken(type: .literal(.identifier))
        }
    }
}
