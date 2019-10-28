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
    
    let maximumFunArgCount: Int = 255
    
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
    
    private func finishCall(withCallee callee: Expr) throws -> Expr {
        var args = [Expr]()
        
        // Check if the argument list is empty (i.e. the next token is `)`), and don't parse arguments if there is one.
        if !self.check(.char(.rightParen)) {
            repeat {
                if args.count >= self.maximumFunArgCount {
                    let peek = self.peek()
                    Dash.reportError(location: ErrorLocation(line: peek.line, column: peek.column),
                                     message: "Functions can have no more than 255 arguments.")
                }
                args.append(try self.expression())
            } while self.match(.char(.comma))
        }
        
        let paren = try self.consume(type: .char(.rightParen), message: "Expected `)` after arguments.")
        return CallExpr(withCallee: callee, paren: paren, args: args)
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
            if self.match(.keyword(.fun)) {
                return try self.function(kind: .function)
            }
            
            if self.match(.keyword(.var)) {
                return try self.varDeclaration()
            }
            
            return try self.statement()
        } catch {
            self.synchronise()
            return nil
        }
    }
    
    func function(kind: CallableKind) throws -> FunctionStmt {
        let name = try self.consume(type: .literal(.identifier), message: "Expected \(kind.description) name.")
        try self.consume(type: .char(.leftParen), message: "Expected `(` after \(kind.description) name.")
        
        var params = [Token]()
        if !self.check(.char(.rightParen)) {
            repeat {
                if params.count >= self.maximumFunArgCount {
                    let peek = self.peek()
                    Dash.reportError(location: ErrorLocation(line: peek.line, column: peek.column),
                                     message: "Functions can have no more than 255 arguments.")
                }
                params.append(try self.consume(type: .literal(.identifier), message: "Expected parameter name."))
            } while self.match(.char(.comma))
        }
        
        try self.consume(type: .char(.rightParen), message: "Expected `)` after parameter list.")
        
        try self.consume(type: .char(.leftBrace), message: "Expected `{` before \(kind.description) body.")
        let body = try self.blockStatement()
        return FunctionStmt(withName: name, params: params, body: body)
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
        if self.match(.keyword(.for)) {
            return try self.forStatement()
        }
        
        if self.match(.keyword(.if)) {
            return try self.ifStatement()
        }
        
        if self.match(.keyword(.return)) {
            return try self.returnStatement()
        }
        
        if self.match(.keyword(.show)) {
            return try self.showStatement()
        }
        
        if self.match(.keyword(.while)) {
            return try self.whileStatement()
        }
        
        if self.match(.char(.leftBrace)) {
            return BlockStmt(withStatements: try self.blockStatement())
        }
        
        return try self.expressionStatement()
    }
    
    func expressionStatement() throws -> Stmt {
        let expr = try self.expression()
        try self.consume(type: .char(.semicolon), message: "Expected `;` after value.")
        
        return ExpressionStmt(withExpr: expr)
    }
    
    func forStatement() throws -> Stmt {
        try self.consume(type: .char(.leftParen), message: "Expected `(` after 'for'.")
        
        var initialiser: Stmt?
        if self.match(.char(.semicolon)) {
            initialiser = nil
        } else if self.match(.keyword(.var)) {
            initialiser = try self.varDeclaration()
        } else {
            initialiser = try self.expressionStatement()
        }
        
        var condition: Expr?
        if !self.check(.char(.semicolon)) {
            condition = try self.expression()
        }
        
        try self.consume(type: .char(.semicolon), message: "Expected `;` after loop condition.")
        
        var increment: Expr?
        if !self.check(.char(.rightParen)) {
            increment = try self.expression()
        }
        
        try self.consume(type: .char(.rightParen), message: "Expected `)` after for-loop clause.")
        
        var body = try self.statement()
        if let increment = increment {
            // Append the "increment" statement after the body of the for-loop block statement
            body = BlockStmt(withStatements: [body, ExpressionStmt(withExpr: increment)])
        }
        
        // Set the body to a basic while loop with the condition being the condition given, otherwise the value `true`
        // to iterate infinitely (or until broken).
        body = WhileStmt(withCondition: condition ?? LiteralExpr(withValue: true), body: body)
       
        if let initialiser = initialiser {
            // If there is an intialiser, append the initialiser statement before the newly-constructed while-loop body.
            body = BlockStmt(withStatements: [initialiser, body])
        }
        
        return body
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
    
    func returnStatement() throws -> Stmt {
        let keyword = self.previous()
        var value: Expr? = nil
        
        if !self.check(.char(.semicolon)) {
            value = try self.expression()
        }
        
        try self.consume(type: .char(.semicolon), message: "Expected `;` after return value.")
        return ReturnStmt(withKeyword: keyword, value: value)
    }
    
    func showStatement() throws -> Stmt {
        let value = try self.expression()
        try self.consume(type: .char(.semicolon), message: "Expected `;` after value.")
        
        return ShowStmt(withExpr: value)
    }
    
    func whileStatement() throws -> Stmt {
        try self.consume(type: .char(.leftParen), message: "Expected `(` after 'while'.")
        let condition = try self.expression()
        try self.consume(type: .char(.rightParen), message: "Expected `)` after while condition.")
        let body = try self.statement()
        
        return WhileStmt(withCondition: condition, body: body)
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
        
        return try self.call()
    }
    
    func call() throws -> Expr {
        // First, parse left operand to the call (the primary expression)
        var expr = try self.primary()
        
        while true {
            if self.match(.char(.leftParen)) {
                // Each time we see a `(`, we call `finishCall(expr:) to parse the call expression using the previously
                // parsed expression as the callee.
                expr = try self.finishCall(withCallee: expr)
            } else {
                break
            }
        }
        
        return expr
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
                 .keyword(.show), .keyword(.return):
                return
            default:
                self.advance()
            }
        }
    }
}
