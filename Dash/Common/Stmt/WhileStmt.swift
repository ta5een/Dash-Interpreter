//
//  WhileStmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class WhileStmt: Stmt {
    let condition: Expr
    let body: Stmt
    
    init(withCondition condition: Expr, body: Stmt) {
        self.condition = condition
        self.body = body
    }
    
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult {
        return try visitor.visitWhileStmt(stmt: self)
    }
}
