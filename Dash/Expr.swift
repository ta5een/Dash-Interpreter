//
//  Expr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

protocol ExprVisitor {
    associatedtype ExprResult

    func visitAssignExpr(expr: AssignExpr) throws -> ExprResult
    func visitBinaryExpr(expr: BinaryExpr) throws -> ExprResult
    func visitGroupingExpr(expr: GroupingExpr) throws -> ExprResult
    func visitLiteralExpr(expr: LiteralExpr) throws -> ExprResult
    func visitLogicalExpr(expr: LogicalExpr) throws -> ExprResult
    func visitUnaryExpr(expr: UnaryExpr) throws -> ExprResult
    func visitVariableExpr(expr: VariableExpr) throws -> ExprResult
}

protocol Expr {
    func accept<V: ExprVisitor>(visitor: V) throws -> V.ExprResult
}
