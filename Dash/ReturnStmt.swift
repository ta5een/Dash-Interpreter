//
//  ReturnStmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class ReturnStmt: Stmt {
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult {
        fatalError("Unimplemented")
    }
}
