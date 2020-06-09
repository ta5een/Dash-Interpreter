//
//  IfSmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class IfStmt: Stmt {
    let condition: Expr
    let thenBranch: Stmt
    let elseBranch: Stmt?
    
    init(withCondition condition: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
        self.condition = condition
        self.thenBranch = thenBranch
        self.elseBranch = elseBranch
    }
    
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult {
        return try visitor.visitIfStmt(stmt: self)
    }
}
