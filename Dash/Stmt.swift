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
    
    func visitBlockStmt(stmt: BlockStmt) throws -> R
    func visitClassStmt(stmt: ClassStmt) throws -> R
    func visitExpressionStmt(stmt: ExpressionStmt) throws -> R
    func visitFunctionStmt(stmt: FunctionStmt) throws -> R
    func visitIfStmt(stmt: IfStmt) throws -> R
    func visitPrintStmt(stmt: PrintStmt) throws -> R
    func visitReturnStmt(stmt: ReturnStmt) throws -> R
    func visitVarStmt(stmt: VarStmt) throws -> R
    func visitWhileStmt(stmt: WhileStmt) throws -> R
}

protocol Stmt {
    func accept<V: ExprVisitor, R>(visitor: V) throws -> R where V.R == R
}
