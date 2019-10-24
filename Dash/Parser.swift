//
//  Parser.swift
//  Dash
//
//  Created by Ta-Seen Islam on 24/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case parseError(token: Token, message: String)
}

class Parser {
    private let tokens: [Token]
    private var current: Int = 0
    
    init(withTokens tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() -> Expr? {
        do {
            return try self.expression()
        } catch {
            return nil
        }
    }
    
    private func match(_ types: TokenType...) -> Bool {
        for type in types {
            if self.check(type) {
                self.advance()
                return true
            }
        }
        
        return false
    }
    
    @discardableResult
    private func consume(type: TokenType, message: String) throws -> Token {
        if self.check(type) {
            return self.advance()
        }
        
        throw reportError(token: self.peek(), message: message)
    }
    
    private func reportError(token: Token, message: String) -> Error {
        Dash.reportError(location: (token.line, 0), message: message)
        return ParseError.parseError(token: token, message: message)
    }
    
    private func check(_ type: TokenType) -> Bool {
        if self.isAtEnd() {
            return false
        }
        
        return self.peek().type == type
    }
    
    @discardableResult
    private func advance() -> Token {
        if !self.isAtEnd() {
            self.current += 1
        }
        
        return self.previous()
    }
    
    private func isAtEnd() -> Bool {
        return self.peek().type == .eof
    }
    
    private func peek() -> Token {
        return self.tokens[self.current]
    }
    
    private func previous() -> Token {
        return self.tokens[self.current - 1]
    }
}

private extension Parser {
    func expression() throws -> Expr {
        return try self.equality()
    }
    
    func equality() throws -> Expr {
        var expr = try self.comparison()
        
        while self.match(.char(.bangEqual), .char(.equalEqual)) {
            let op = self.previous()
            let right = try self.comparison()
            expr = BinaryExpr(left: expr, operator: op, right: right)
        }
        
        return expr
    }
    
    func comparison() throws -> Expr {
        var expr = try self.addition()
        
        while self.match(.char(.less), .char(.lessEqual), .char(.greater), .char(.greaterEqual)) {
            let op = self.previous()
            let right = try self.addition()
            expr = BinaryExpr(left: expr, operator: op, right: right)
        }
        
        return expr
    }
    
    func addition() throws -> Expr {
        var expr = try self.multiplication()
        
        while self.match(.char(.plus), .char(.minus)) {
            let op = self.previous()
            let right = try self.multiplication()
            expr = BinaryExpr(left: expr, operator: op, right: right)
        }
        
        return expr
    }
    
    func multiplication() throws -> Expr {
        var expr = try self.unary()
        
        while self.match(.char(.asterisk), .char(.slash)) {
            let op = self.previous()
            let right = try self.unary()
            expr = BinaryExpr(left: expr, operator: op, right: right)
        }
        
        return expr
    }
    
    func unary() throws -> Expr {
        if self.match(.char(.bang), .char(.minus)) {
            let op = self.previous()
            let right = try self.unary()
            return UnaryExpr(withOperator: op, rightExpr: right)
        }
        
        return try self.primary()
    }
    
    func primary() throws -> Expr {
        if self.match(.keyword(.false)) { return LiteralExpr(withValue: false) }
        if self.match(.keyword(.true)) { return LiteralExpr(withValue: true) }
        if self.match(.keyword(.nothing)) { return LiteralExpr(withValue: nil) }
        
        if self.match(.literal(.number), .literal(.string)) {
            return LiteralExpr(withValue: self.previous().literal)
        }
        
        if self.match(.char(.leftParen)) {
            let expr = try self.expression()
            try self.consume(type: .char(.rightParen), message: "Expected `)` after expression.")
            return GroupingExpr(withExpression: expr)
        }
        
        throw ParseError.parseError(token: self.peek(), message: "Expected expression")
    }
}

private extension Parser {
    func synchronise() {
        self.advance()
        
        while !self.isAtEnd() {
            if self.previous().type == .newline {
                return
            }
            
            switch self.peek().type {
            case .keyword(.class), .keyword(.fun), .keyword(.var), .keyword(.for), .keyword(.if), .keyword(.while),
                 .keyword(.dbg), .keyword(.return):
                return
            default:
                self.advance()
            }
        }
    }
}
