//
//  AstPrinter.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class AstPrinter {
    public func interpret(statements: [Stmt]) {
        do {
            try statements.forEach { Swift.print(try self.print(stmt: $0)) }
        } catch {
            Dash.reportRuntimeError(error: error as! RuntimeError)
        }
    }
    
    private func print(stmt: Stmt) throws -> String {
        return try stmt.accept(visitor: self)
    }
    
    private func print(expr: Expr) throws -> String {
        return try expr.accept(visitor: self)
    }
    
    private func parenthesise(name: String, stmts: Stmt...) throws -> String {
        var string = ""
        try stmts.forEach { stmt in string.append(" \(try stmt.accept(visitor: self))") }
        string.append(")")
        
        return string
    }
    
    private func parenthesise(name: String, exprs: Expr...) throws -> String {
        var string = "(\(name)"
        try exprs.forEach { expr in string.append(" \(try expr.accept(visitor: self))") }
        string.append(")")
        
        return string
    }
}

extension AstPrinter: StmtVisitor {
    typealias StmtResult = String
    
    func visitBlockStmt(stmt: BlockStmt) throws -> StmtResult {
        return ""
    }
    
    func visitClassStmt(stmt: ClassStmt) throws -> StmtResult {
        fatalError("Unimplemented")
    }
    
    func visitExpressionStmt(stmt: ExpressionStmt) throws -> StmtResult {
        return try self.parenthesise(name: "expr", stmts: stmt)
    }
    
    func visitFunctionStmt(stmt: FunctionStmt) throws -> StmtResult {
        fatalError("Unimplemented")
    }
    
    func visitIfStmt(stmt: IfStmt) throws -> StmtResult {
        if let elseBranch = stmt.elseBranch {
            return try self.parenthesise(name: "if \(try self.parenthesise(name: "", exprs: stmt.condition))",
                                         stmts: stmt.thenBranch, elseBranch)
        } else {
            return try self.parenthesise(name: "if \(try self.parenthesise(name: "", exprs: stmt.condition))",
                                         stmts: stmt.thenBranch)
        }
    }
    
    func visitPrintStmt(stmt: PrintStmt) throws -> StmtResult {
        return try self.parenthesise(name: "print", exprs: stmt.expression)
    }
    
    func visitReturnStmt(stmt: ReturnStmt) throws -> StmtResult {
        fatalError("Unimplemented")
    }
    
    func visitVarStmt(stmt: VarStmt) throws -> StmtResult {
        return try self.parenthesise(name: "var \(stmt.token.lexeme)", exprs: stmt.initialiser ?? LiteralExpr(withValue: nil))
    }
    
    func visitWhileStmt(stmt: WhileStmt) throws -> StmtResult {
        return try self.parenthesise(name: "while \(try self.parenthesise(name: "", exprs: stmt.condition))", stmts: stmt.body)
    }
}

extension AstPrinter: ExprVisitor {
    typealias ExprResult = String
    
    func visitAssignExpr(expr: AssignExpr) throws -> ExprResult {
        return try self.parenthesise(name: expr.name.lexeme, exprs: expr.value)
    }

    func visitBinaryExpr(expr: BinaryExpr) throws -> ExprResult {
        return try self.parenthesise(name: expr.operator.lexeme, exprs: expr.left, expr.right)
    }

    func visitGroupingExpr(expr: GroupingExpr) throws -> ExprResult {
        return try self.parenthesise(name: ":", exprs: expr.expression)
    }

    func visitLiteralExpr(expr: LiteralExpr) throws -> ExprResult {
        return expr.description
    }
    
    func visitLogicalExpr(expr: LogicalExpr) throws -> String {
        return try self.parenthesise(name: expr.operator.lexeme, exprs: expr.left, expr.right)
    }

    func visitUnaryExpr(expr: UnaryExpr) throws -> ExprResult {
        return try self.parenthesise(name: expr.operator.lexeme, exprs: expr.right)
    }
    
    func visitVariableExpr(expr: VariableExpr) throws -> String {
        return try self.parenthesise(name: "var", exprs: LiteralExpr(withValue: nil))
    }
}
