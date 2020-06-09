//
//  AssignExpr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 26/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class AssignExpr: Expr {
    let name: Token
    let value: Expr
    
    init(withName name: Token, value: Expr) {
        self.name = name
        self.value = value
    }
    
    func accept<V: ExprVisitor>(visitor: V) throws -> V.ExprResult {
        return try visitor.visitAssignExpr(expr: self)
    }
}
