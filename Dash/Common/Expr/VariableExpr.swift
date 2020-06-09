//
//  VariableExpr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 26/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class VariableExpr: Expr {
    let name: Token
    
    init(withName name: Token) {
        self.name = name
    }
    
    func accept<V: ExprVisitor>(visitor: V) throws -> V.ExprResult {
        return try visitor.visitVariableExpr(expr: self)
    }
}
