//
//  ReturnStmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class ReturnStmt: Stmt {
    let keyword: Token
    let value: Expr?
    
    init(withKeyword keyword: Token, value: Expr?) {
        self.keyword = keyword
        self.value = value
    }
    
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult {
        return try visitor.visitReturnStmt(stmt: self)
    }
}
