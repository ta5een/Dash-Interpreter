//
//  Expr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

protocol ExprVisitor {
    associatedtype R
    
    func visitBinaryExpr(expr: BinaryExpr) throws -> R
    func visitGroupingExpr(expr: GroupingExpr) throws -> R
    func visitLiteralExpr(expr: LiteralExpr) throws -> R
    func visitUnaryExpr(expr: UnaryExpr) throws -> R
}

protocol Expr {
    func accept<V: ExprVisitor, R>(visitor: V) throws -> R where V.R == R
}
