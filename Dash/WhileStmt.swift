//
//  WhileStmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class WhileStmt: Stmt {
    func accept<V, R>(visitor: V) throws -> R where V : ExprVisitor, R == V.R {
        fatalError("Unimplemented")
    }
}
