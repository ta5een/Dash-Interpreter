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
    
    func parse() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !self.isAtEnd() {
            if let declaration = self.declaration() {
                statements.append(declaration)
            }
        }
        
        return statements
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
        if self.check(type) { return self.advance() }
        
        throw self.reportError(token: self.peek(), message: message)
    }
    
    private func reportError(token: Token, message: String) -> Error {
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

// MARK: - Statements
private extension Parser {
    func declaration() -> Stmt? {
        do {
            if self.match(.keyword(.var)) {
                return try self.varDeclaration()
            }
            
            return try self.statement()
        } catch {
            self.synchronise()
            return nil
        }
    }
    
    func varDeclaration() throws -> Stmt {
        let name = try self.consume(type: .literal(.identifier), message: "Expected variables name")
        
        var initialiser: Expr? = nil
        if (self.match(.char(.equal))) {
            initialiser = try self.expression()
        }
        
        try self.consume(type: .char(.semicolon), message: "Expected `;` after variable declaration")
        return VarStmt(withToken: name, initialiser: initialiser)
    }
    
    func statement() throws -> Stmt {
        if self.match(.keyword(.if)) {
            return try self.ifStatement()
        }
        
        if self.match(.keyword(.print)) {
            return try self.printStatement()
        }
        
        if self.match(.char(.leftBrace)) {
            return BlockStmt(withStatements: try self.blockStatement())
        }
        
        return try self.expressionStatement()
    }
    
    func expressionStatement() throws -> Stmt {
        let expr = try self.expression()
        try self.consume(type: .char(.semicolon), message: "Expected `;` after value")
        
        return ExpressionStmt(withExpr: expr)
    }
    
    func ifStatement() throws -> Stmt {
        try self.consume(type: .char(.leftParen), message: "Expected `(` after 'if'.")
        let condition = try self.expression()
        try self.consume(type: .char(.rightParen), message: "Expected `)` after if condition.")
        
        let thenBranch = try self.statement()
        var elseBranch: Stmt? = nil
        if self.match(.keyword(.else)) {
            elseBranch = try self.statement()
        }
        
        return IfStmt(withCondition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
    }
    
    func printStatement() throws -> Stmt {
        let value = try self.expression()
        try self.consume(type: .char(.semicolon), message: "Expected `;` after value")
        
        return PrintStmt(withExpr: value)
    }
    
    func blockStatement() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !self.check(.char(.rightBrace)) && !self.isAtEnd() {
            if let declaration = self.declaration() {
                statements.append(declaration)
            }
        }
        
        try self.consume(type: .char(.rightBrace), message: "Expected `}` after block.")
        return statements
    }
}

// MARK: - Expressions
private extension Parser {
    func expression() throws -> Expr {
        return try self.assignment()
    }
    
    func assignment() throws -> Expr {
        let expr = try self.or()
        
        if self.match(.char(.equal)) {
            let equals = self.previous()
            let value = try self.assignment()
            
            if expr is VariableExpr {
                let name = (expr as! VariableExpr).name
                return AssignExpr(withName: name, value: value)
            }
            
            Dash.reportError(location: ErrorLocation(line: equals.line, column: equals.column),
                             message: "Invalid assignment target",
                             help: nil)
        }
        
        return expr
    }
    
    func or() throws -> Expr {
        var expr = try self.and()
        
        while self.match(.keyword(.or)) {
            let `operator` = self.previous()
            let right = try self.and()
            expr = LogicalExpr(left: expr, operator: `operator`, right: right)
        }
        
        return expr
    }
    
    func and() throws -> Expr {
        var expr = try self.equality()
        
        while self.match(.keyword(.and)) {
            let `operator` = self.previous()
            let right = try self.equality()
            expr = LogicalExpr(left: expr, operator: `operator`, right: right)
        }
        
        return expr
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
        
        if self.match(.literal(.identifier)) {
            return VariableExpr(withName: self.previous())
        }
        
        if self.match(.char(.leftParen)) {
            let expr = try self.expression()
            try self.consume(type: .char(.rightParen), message: "Expected `)` after expression.")
            return GroupingExpr(withExpression: expr)
        }
        
        throw ParseError.parseError(token: self.peek(), message: "Expected expression")
    }
}

// MARK: - Synchronising
private extension Parser {
    func synchronise() {
        self.advance()
        
        while !self.isAtEnd() {
            if self.previous().type == .char(.semicolon) {
                return
            }
            
            switch self.peek().type {
            case .keyword(.class), .keyword(.fun), .keyword(.var), .keyword(.for), .keyword(.if), .keyword(.while),
                 .keyword(.print), .keyword(.return):
                return
            default:
                self.advance()
            }
        }
    }
}
