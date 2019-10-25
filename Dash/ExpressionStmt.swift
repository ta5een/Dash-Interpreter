//
//  ExprStmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class ExpressionStmt: Stmt {
    var expression: Expr
    
    init(withExpr expr: Expr) {
        self.expression = expr
    }
    
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult {
        fatalError("Unimplemented")
    }
}
