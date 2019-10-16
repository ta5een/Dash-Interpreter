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
        
        self.tokens.append(Token(withType: .eof, lexeme: "", literal: nil, line: self.line))
        return self.tokens
    }
    
    func scan() {
        switch self.advance() {
        case "(":   self.addToken(type: .leftParen)
        case ")":   self.addToken(type: .rightParen)
        case "{":   self.addToken(type: .leftBrace)
        case "}":   self.addToken(type: .rightParen)
        
        case "*":   self.addToken(type: .asterisk)
        case ",":   self.addToken(type: .comma)
        case ".":   self.addToken(type: .dot)
        case "-":   self.addToken(type: .minus)
        case "+":   self.addToken(type: .plus)
        case ";":   self.addToken(type: .semicolon)
        case "/":   self.addToken(type: .slash)
            
        case "!":   self.addToken(type: (self.nextTokenMatches("=") ? .bangEqual : .bang))
        case "=":   self.addToken(type: (self.nextTokenMatches("=") ? .equalEqual : .equal))
        case "<":   self.addToken(type: (self.nextTokenMatches("=") ? .lessEqual : .less))
        case ">":   self.addToken(type: (self.nextTokenMatches("=") ? .greaterEqual : .greater))
            
        case "#":   while self.peek() != "\n" && !self.isAtEnd { _ = self.advance() }
            
        case "\n":  self.line += 1
        case "", " ", "\r", "\t": break
            
        case "\"":  self.startString(fromIndex: self.current - 1)
        
        case let char:
            Dash.reportError(location: (self.line, self.current - 1), message: "Unexpected character: '\(char)'")
        }
    }
    
    func nextTokenMatches(_ expected: String) -> Bool {
        if self.isAtEnd { return false }
        if self.source[self.current] != expected { return false }
        
        self.current += 1
        return true
    }
    
    // FIXME: Perhaps find a way to to return a `Character` instead?
    func advance() -> String {
        self.current += 1
        return self.source[self.current - 1]
    }
    
    func peek() -> String {
        if self.isAtEnd { return "\0" }
        return self.source[self.current]
    }
    
    func startString(fromIndex index: Int) {
        while self.peek() != "\"" && !self.isAtEnd {
            if (self.peek() == "\n") {
                self.line += 1
            }
            
            _ = self.advance()
        }
        
        if self.isAtEnd {
            Dash.reportError(location: (self.line, self.current - 1), message: "Unterminated string")
            return
        }
        
        // The closing `"`
        _ = self.advance()
        
        // Trim the surrounding quotes
        self.addToken(type: .string, literal: self.source[(self.start + 1) ..< self.current - 1])
    }
    
    func addToken(type: TokenType, literal: Literal? = nil) {
        self.tokens.append(Token(withType: type,
                                 lexeme: self.source[self.start ..< self.current],
                                 literal: literal,
                                 line: self.line))
    }
    
}
