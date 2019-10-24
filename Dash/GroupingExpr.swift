//
//  GroupingExpr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class GroupingExpr: Expr {
    let expression: Expr
    
    init(withExpression expression: Expr) {
        self.expression = expression
    }
    
    func accept<V: Visitor, R>(visitor: V) throws -> R where V.R == R {
        return try visitor.visitGroupingExpr(expr: self)
    }
}
