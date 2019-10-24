//
//  UnaryExpr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class UnaryExpr: Expr {
    let `operator`: Token
    let right: Expr
    
    init(withOperator operator: Token, rightExpr right: Expr) {
        self.operator = `operator`
        self.right = right
    }
    
    func accept<V: Visitor, R>(visitor: V) throws -> R where V.R == R {
        return try visitor.visitUnaryExpr(expr: self)
    }    
}
