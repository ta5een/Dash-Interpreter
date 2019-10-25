//
//  Stmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

protocol StmtVisitor {
    associatedtype R
    
    func visitBlockStmt() throws -> R
    func visitClassStmt() throws -> R
    func visitExpressionStmt() throws -> R
    func visitFunctionStmt() throws -> R
    func visitIfStmt() throws -> R
    func visitPrintStmt() throws -> R
    func visitReturnStmt() throws -> R
    func visitVarStmt() throws -> R
    func visitWhileStmt() throws -> R
}

protocol Stmt {
    func accept<V: ExprVisitor, R>(visitor: V) throws -> R where V.R == R
}
