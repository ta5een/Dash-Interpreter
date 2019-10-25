//
//  Stmt.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

protocol StmtVisitor {
    associatedtype StmtResult
    
    func visitBlockStmt(stmt: BlockStmt) throws -> StmtResult
    func visitClassStmt(stmt: ClassStmt) throws -> StmtResult
    func visitExpressionStmt(stmt: ExpressionStmt) throws -> StmtResult
    func visitFunctionStmt(stmt: FunctionStmt) throws -> StmtResult
    func visitIfStmt(stmt: IfStmt) throws -> StmtResult
    func visitPrintStmt(stmt: PrintStmt) throws -> StmtResult
    func visitReturnStmt(stmt: ReturnStmt) throws -> StmtResult
    func visitVarStmt(stmt: VarStmt) throws -> StmtResult
    func visitWhileStmt(stmt: WhileStmt) throws -> StmtResult
}

protocol Stmt {
    func accept<V: StmtVisitor>(visitor: V) throws -> V.StmtResult
}
