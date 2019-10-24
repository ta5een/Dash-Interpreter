//
//  Parser.swift
//  Dash
//
//  Created by Ta-Seen Islam on 24/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class Parser {
    
    private let tokens: [Token]
    private var current: Int = 0
    
    init(withTokens tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() -> Expr? {
        switch self.expression() {
        case .success(let expr):
            return expr
        case .failure(let error):
            print(error.localizedDescription)
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
    private func consume(type: TokenType, message: String) -> Result<Token, ParseError> {
        if self.check(type) {
            return .success(self.advance())
        }
        
        return .failure(reportError(token: self.peek(), message: message))
    }
    
    private func reportError(token: Token, message: String) -> ParseError {
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
    
    func expression() -> Result<Expr, ParseError> {
        return self.equality()
    }
    
    func equality() -> Result<Expr, ParseError> {
        var expr = self.comparison()
        
        while self.match(.char(.bangEqual), .char(.equalEqual)) {
            switch (expr, self.comparison()) {
            case (.success(let left), .success(let right)):
                let op = self.previous()
                expr = .success(BinaryExpr(left: left, operator: op, right: right))
            case (.failure(let error), _), (_, .failure(let error)):
                return .failure(error)
            default:
                fatalError("UNEXPECTED")
            }
        }
        
        return expr
    }
    
    func comparison() -> Result<Expr, ParseError> {
        var expr = self.addition()
        
        while self.match(.char(.less), .char(.lessEqual), .char(.greater), .char(.greaterEqual)) {
            switch (expr, self.addition()) {
            case (.success(let left), .success(let right)):
                let op = self.previous()
                expr = .success(BinaryExpr(left: left, operator: op, right: right))
            case (.failure(let error), _), (_, .failure(let error)):
                return .failure(error)
            default:
                fatalError("UNEXPECTED")
            }
        }
        
        return expr
    }
    
    func addition() -> Result<Expr, ParseError> {
        var expr = self.multiplication()
        
        while self.match(.char(.plus), .char(.minus)) {
            switch (expr, self.multiplication()) {
            case (.success(let left), .success(let right)):
                let op = self.previous()
                expr = .success(BinaryExpr(left: left, operator: op, right: right))
            case (.failure(let error), _), (_, .failure(let error)):
                return .failure(error)
            default:
                fatalError("UNEXPECTED")
            }
        }
        
        return expr
    }
    
    func multiplication() -> Result<Expr, ParseError> {
        var expr = self.unary()
        
        while self.match(.char(.asterisk), .char(.slash)) {
            switch (expr, self.unary()) {
            case (.success(let left), .success(let right)):
                let op = self.previous()
                expr = .success(BinaryExpr(left: left, operator: op, right: right))
            case (.failure(let error), _), (_, .failure(let error)):
                return .failure(error)
            default:
                fatalError("UNEXPECTED")
            }
        }
        
        return expr
    }
    
    func unary() -> Result<Expr, ParseError> {
        if self.match(.char(.bang), .char(.minus)) {
            switch self.unary() {
            case .success(let right):
                let op = self.previous()
                return .success(UnaryExpr(withOperator: op, rightExpr: right))
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return self.primary()
    }
    
    func primary() -> Result<Expr, ParseError> {
        if self.match(.keyword(.false)) {
            return .success(LiteralExpr(withValue: false))
        }
        
        if self.match(.keyword(.true)) {
            return .success(LiteralExpr(withValue: true))
        }
        
        if self.match(.keyword(.nothing)) {
            return .success(LiteralExpr(withValue: nil))
        }
        
        if self.match(.literal(.number), .literal(.string)) {
            return .success(LiteralExpr(withValue: self.previous().literal))
        }
        
        if self.match(.char(.leftParen)) {
            switch self.consume(type: .char(.rightParen), message: "Expected `)` after expression") {
            case .success(_):
                switch self.expression() {
                case .success(let expr):
                    return .success(GroupingExpr(withExpression: expr))
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return .failure(ParseError.parseError(token: self.peek(), message: "Expected expression"))
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
