//
//  Expr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

protocol Visitor {
    associatedtype R
    
    func visitBinaryExpr(expr: BinaryExpr) -> R
    func visitGroupingExpr(expr: GroupingExpr) -> R
    func visitLiteralExpr(expr: LiteralExpr) -> R
    func visitUnaryExpr(expr: UnaryExpr) -> R
}

protocol Expr {
    func accept<V: Visitor, R>(visitor: V) -> R where V.R == R
}
