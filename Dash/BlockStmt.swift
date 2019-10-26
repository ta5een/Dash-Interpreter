//
//  BlockStmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class BlockStmt: Stmt {
    let statements: [Stmt]
    
    init(withStatements statements: [Stmt]) {
        self.statements = statements
    }
    
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult {
        return try visitor.visitBlockStmt(stmt: self)
    }
}
