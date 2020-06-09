//
//  VarStmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class VarStmt: Stmt {
    let token: Token
    let initialiser: Expr?
    
    init(withToken token: Token, initialiser: Expr?) {
        self.token = token
        self.initialiser = initialiser
    }
    
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult {
        return try visitor.visitVarStmt(stmt: self)
    }
}
