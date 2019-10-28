//
//  CallExpr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 28/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

enum CallableKind: CustomStringConvertible {
    case function
    
    var description: String {
        switch self {
        case .function:
            return "function"
        }
    }
}

protocol Callable {
    var arity: Int { get }
    func call(interpreter: Interpreter, arguments: [Any?]) -> Any?
}

class CallExpr: Expr {
    let callee: Expr
    let paren: Token
    let args: [Expr]
    
    init(withCallee callee: Expr, paren: Token, args: [Expr]) {
        self.callee = callee
        self.paren = paren
        self.args = args
    }
    
    func accept<V: ExprVisitor>(visitor: V) throws -> V.ExprResult {
        return try visitor.visitCallExpr(expr: self)
    }
}

class ClockNativeFun: Callable, CustomStringConvertible {
    var arity: Int = 0
    
    func call(interpreter: Interpreter, arguments: [Any?]) -> Any? {
        return Date().timeIntervalSinceReferenceDate
    }
    
    var description: String {
        return "(native-fun clock [])"
    }
}

class PrintNativeFun: Callable, CustomStringConvertible {
    var arity: Int = 1
    
    func call(interpreter: Interpreter, arguments: [Any?]) -> Any? {
        if let str = arguments[0] as? CustomStringConvertible {
            print(str, terminator: "")
        }
        
        return nil
    }
    
    var description: String {
        return "(native-fun print [string])"
    }
}

class PrintLnNativeFun: Callable, CustomStringConvertible {
    var arity: Int = 1
    
    func call(interpreter: Interpreter, arguments: [Any?]) -> Any? {
        if let str = arguments[0] as? CustomStringConvertible {
            print(str)
        }
        
        return nil
    }
    
    var description: String {
        return "(native-fun println [string])"
    }
}

class Function: Callable, CustomStringConvertible {
    var declaration: FunctionStmt
    var arity: Int
    
    init(withDeclaration declaration: FunctionStmt) {
        self.declaration = declaration
        self.arity = declaration.params.count
    }
    
    func call(interpreter: Interpreter, arguments: [Any?]) -> Any? {
        let environment = Environment(withEnclosingEnvironment: interpreter.globals)
        for (i, param) in self.declaration.params.enumerated() {
            environment.define(name: param.lexeme, withValue: arguments[i])
        }
        
        interpreter.executeBlock(withStatements: self.declaration.body, environment: environment)
        return nil
    }
    
    var description: String {
        "(fun \(self.declaration.name.lexeme) \(self.declaration.params.map { $0.lexeme }))"
    }
}
