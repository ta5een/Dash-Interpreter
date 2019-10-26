//
//  AstPrinter.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class AstPrinter {
    func print(expr: Expr) throws -> String {
        return try expr.accept(visitor: self)
    }
    
    func parenthesise(name: String, exprs: Expr...) throws -> String {
        var string = "(\(name)"
        try exprs.forEach { expr in string.append(" \(try expr.accept(visitor: self))") }
        string.append(")")
        
        return string
    }
}

extension AstPrinter: ExprVisitor {
    typealias R = String
    
    func visitAssignExpr(expr: AssignExpr) throws -> R {
        fatalError("Unimplemented")
    }

    func visitBinaryExpr(expr: BinaryExpr) throws -> R {
        return try self.parenthesise(name: expr.operator.lexeme, exprs: expr.left, expr.right)
    }

    func visitGroupingExpr(expr: GroupingExpr) throws -> R {
        return try self.parenthesise(name: ":", exprs: expr.expression)
    }

    func visitLiteralExpr(expr: LiteralExpr) throws -> R {
        return expr.description
    }

    func visitUnaryExpr(expr: UnaryExpr) throws -> R {
        return try self.parenthesise(name: expr.operator.lexeme, exprs: expr.right)
    }
    
    func visitVariableExpr(expr: VariableExpr) throws -> String {
        return try self.parenthesise(name: "var \(expr.name.lexeme)")
    }
}
