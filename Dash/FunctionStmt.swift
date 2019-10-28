//
//  FunctionStmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class FunctionStmt: Stmt {
    let name: Token
    let params: [Token]
    let body: [Stmt]
    
    init(withName name: Token, params: [Token], body: [Stmt]) {
        self.name = name
        self.params = params
        self.body = body
    }
    
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult {
        return try visitor.visitFunctionStmt(stmt: self)
    }
}
