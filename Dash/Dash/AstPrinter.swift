//
//  AstPrinter.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class AstPrinter {
    
    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
    }
    
    func parenthesise(name: String, exprs: Expr...) -> String {
        var string = "(\(name)"
        exprs.forEach { expr in string.append(" \(expr.accept(visitor: self))") }
        string.append(")")
        
        return string
    }
    
}

extension AstPrinter: Visitor {

    typealias R = String

    func visitBinaryExpr(expr: BinaryExpr) -> R {
        return self.parenthesise(name: expr.operator.lexeme, exprs: expr.left, expr.right)
    }

    func visitGroupingExpr(expr: GroupingExpr) -> R {
        return self.parenthesise(name: "group", exprs: expr.expression)
    }

    func visitLiteralExpr(expr: LiteralExpr) -> R {
        return expr.description
    }

    func visitUnaryExpr(expr: UnaryExpr) -> R {
        return self.parenthesise(name: expr.operator.lexeme, exprs: expr.right)
    }

}
