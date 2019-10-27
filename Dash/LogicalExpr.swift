//
//  LogicalExpr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 27/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class LogicalExpr: Expr {
    let left: Expr
    let `operator`: Token
    let right: Expr
    
    init(left: Expr, operator: Token, right: Expr) {
        self.left = left
        self.operator = `operator`
        self.right = right
    }
    
    func accept<V: ExprVisitor>(visitor: V) throws -> V.ExprResult {
        return try visitor.visitLogicalExpr(expr: self)
    }
}
