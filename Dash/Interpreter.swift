//
//  Interpreter.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

enum Return: Error {
    case withValue(_ value: Any?)
}

enum RuntimeError: Error {
    case invalidOperand(token: Token, message: String, help: String? = nil)
    case invalidCall(token: Token, message: String, help: String? = nil)
    case invalidNumberOfArguments(token: Token, message: String, help: String? = nil)
    case undefinedVariable(token: Token)
}

class Interpreter {
    let globals: Environment = Environment()
    private var environment: Environment
    
    init() {
        self.globals.define(name: "clock", withValue: ClockNativeFun())
        self.globals.define(name: "print", withValue: PrintNativeFun())
        self.globals.define(name: "println", withValue: PrintLnNativeFun())
        self.environment = self.globals
    }
    
    public func interpret(statements: [Stmt]) {
        do {
            try statements.forEach { try self.execute(stmt: $0) }
        } catch {
            Dash.reportRuntimeError(error: error as! RuntimeError)
        }
    }
    
    private func stringify(object: Any?) -> String {
        if let object = object {
            return String(describing: object)
        } else {
            return "(nothing)"
        }
    }
    
    func execute(stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func executeBlock(withStatements statements: [Stmt], environment: Environment) throws {
        let previous = self.environment
        defer { self.environment = previous }
        
        do {
            self.environment = environment
            try statements.forEach { try self.execute(stmt: $0) }
        } catch let error as RuntimeError {
            Dash.reportRuntimeError(error: error)
        } catch let error as Return {
            throw error
        } catch {
            Dash.reportError(location: nil, message: "Failed to execute statement(s) in current environment scope.")
        }
    }
    
    @discardableResult
    private func evaluate(expr: Expr) throws -> Any? {
        return try expr.accept(visitor: self)
    }
    
    private func checkNumberOperand(operator: Token, operand: Any?) throws {
        if operand is Double { return }
        throw RuntimeError.invalidOperand(token: `operator`, message: "Operand must be a number")
    }
    
    private func checkNumberOperands(operator: Token, left: Any?, right: Any?) throws {
        if (left is Double) && (right is Double) { return }
        throw RuntimeError.invalidOperand(token: `operator`, message: "Operands must be numbers")
    }
    
    private func isTruthy(_ object: Any?) -> Bool {
        if object == nil { return false }
        if object is Bool { return (object as! Bool) }
        
        return true
    }
    
    private func equate<E: Equatable>(_ left: E, _ right: E) -> Bool {
        return left == right
    }
    
    private func equate<E>(_ left: E, _ right: E) -> Bool {
        return false
    }
    
    private func isEqual(_ left: Any?, _ right: Any?) -> Bool {
        if (left == nil) && (right == nil) { return true }
        if (left == nil) || (right == nil) { return false }
        
        if (left is Double) && (right is Double) { return (left as! Double) == (right as! Double) }
        if (left is String) && (right is String) { return (left as! String) == (right as! String) }
        if (left is Bool) && (right is Bool) { return (left as! Bool) == (right as! Bool) }
        
        return self.equate(left, right)
    }
}

// MARK: - Interpreter + ExprVisitor
extension Interpreter: ExprVisitor {
    typealias ExprResult = Any?
    
    func visitAssignExpr(expr: AssignExpr) throws -> ExprResult {
        let value = try self.evaluate(expr: expr.value)
        try self.environment.assign(name: expr.name, withValue: value)
        return value
    }

    func visitBinaryExpr(expr: BinaryExpr) throws -> ExprResult {
        let left = try self.evaluate(expr: expr.left)
        let right = try self.evaluate(expr: expr.right)
        
        switch expr.operator.type {
        case .char(.plus):
            if (left is Double) && (right is Double) {
                return (left as! Double) + (right as! Double)
            }
            
            if (left is String) && (right is String) {
                return (left as! String) + (right as! String)
            }
            
            throw RuntimeError.invalidOperand(token: expr.operator,
                                              message: "Operands must be two numbers or two strings.")
        case .char(.minus):
            try self.checkNumberOperands(operator: expr.operator, left: left, right: right)
            return (left as! Double) - (right as! Double)
        case .char(.asterisk):
            try self.checkNumberOperands(operator: expr.operator, left: left, right: right)
           return (left as! Double) * (right as! Double)
        case .char(.slash):
            try self.checkNumberOperands(operator: expr.operator, left: left, right: right)
            return (left as! Double) / (right as! Double)
            
        case .char(.less):
            try self.checkNumberOperands(operator: expr.operator, left: left, right: right)
            return (left as! Double) < (right as! Double)
        case .char(.lessEqual):
            try self.checkNumberOperands(operator: expr.operator, left: left, right: right)
            return (left as! Double) <= (right as! Double)
        case .char(.greater):
            try self.checkNumberOperands(operator: expr.operator, left: left, right: right)
            return (left as! Double) > (right as! Double)
        case .char(.greaterEqual):
            try self.checkNumberOperands(operator: expr.operator, left: left, right: right)
            return (left as! Double) >= (right as! Double)
            
        case .char(.bangEqual):
            return !self.isEqual(left, right)
        case .char(.equalEqual):
            return self.isEqual(left, right)
        default:
            fatalError("Unreachable")
        }
    }
    
    func visitCallExpr(expr: CallExpr) throws -> ExprResult {
        let callee = try self.evaluate(expr: expr.callee)
        
        var args = [Any?]()
        for arg in expr.args {
            args.append(try self.evaluate(expr: arg))
        }
        
        if let function = callee as? Callable {
            if args.count != function.arity {
                throw RuntimeError.invalidNumberOfArguments(
                    token: expr.paren,
                    message: "Invalid number of arguments.",
                    help: "Expected \(function.arity) arguments, but found \(args.count)."
                )
            }
            return function.call(interpreter: self, arguments: args)
        } else {
            throw RuntimeError.invalidCall(
                token: expr.paren,
                message: "Invalid call to value.",
                help: "You can only call functions and class methods."
            )
        }
    }

    func visitGroupingExpr(expr: GroupingExpr) throws -> ExprResult {
        return try self.evaluate(expr: expr.expression)
    }

    func visitLiteralExpr(expr: LiteralExpr) throws -> ExprResult {
        return expr.value
    }
    
    func visitLogicalExpr(expr: LogicalExpr) throws -> Any? {
        let left = try self.evaluate(expr: expr.left)
        
        if expr.operator.type == .keyword(.or) {
            if self.isTruthy(left) {
                return left
            }
        } else {
            if !self.isTruthy(left) {
                return left
            }
        }
        
        return try self.evaluate(expr: expr.right)
    }

    func visitUnaryExpr(expr: UnaryExpr) throws -> ExprResult {
        // TODO: `right` should be `Any?` to allow `nil` values
        let right = try self.evaluate(expr: expr.right)
        
        switch expr.operator.type {
        case .char(.minus):
            try self.checkNumberOperand(operator: expr.operator, operand: right)
            return -(right as! Double)
        case .char(.bang):
            return !self.isTruthy(right)
        default:
            fatalError("Unreachable")
        }
    }
    
    func visitVariableExpr(expr: VariableExpr) throws -> ExprResult {
        return try self.environment.getValue(withName: expr.name)
    }
}

// MARK: - Interpreter + StmtVisitor
extension Interpreter: StmtVisitor {
    typealias StmtResult = Void
    
    func visitBlockStmt(stmt: BlockStmt) throws -> StmtResult {
        try self.executeBlock(withStatements: stmt.statements, environment: Environment(withEnclosingEnvironment: self.environment))
    }
    
    func visitClassStmt(stmt: ClassStmt) throws -> StmtResult {
        fatalError("Unimplemented")
    }
    
    func visitExpressionStmt(stmt: ExpressionStmt) throws -> StmtResult {
        try self.evaluate(expr: stmt.expression)
    }
    
    func visitFunctionStmt(stmt: FunctionStmt) throws -> StmtResult {
        let function = Function(withDeclaration: stmt)
        self.environment.define(name: stmt.name.lexeme, withValue: function)
    }
    
    func visitIfStmt(stmt: IfStmt) throws -> StmtResult {
        if self.isTruthy(try self.evaluate(expr: stmt.condition)) {
            try self.execute(stmt: stmt.thenBranch)
        } else if let elseBranch = stmt.elseBranch {
            try self.execute(stmt: elseBranch)
        }
    }
    
    func visitReturnStmt(stmt: ReturnStmt) throws -> StmtResult {
        var value: Any? = nil
        if let stmtVal = stmt.value {
            value = try self.evaluate(expr: stmtVal)
        }
        
        throw Return.withValue(value)
    }
    
    func visitShowStmt(stmt: ShowStmt) throws -> StmtResult {
        let value = try self.evaluate(expr: stmt.expression)
        print(self.stringify(object: value))
    }
    
    func visitVarStmt(stmt: VarStmt) throws -> StmtResult {
        var value: Any? = nil
        
        if let initialiser = stmt.initialiser {
            value = try self.evaluate(expr: initialiser)
        }
        
        self.environment.define(name: stmt.token.lexeme, withValue: value)
    }
    
    func visitWhileStmt(stmt: WhileStmt) throws -> StmtResult {
        while self.isTruthy(try self.evaluate(expr: stmt.condition)) {
            try self.execute(stmt: stmt.body)
        }
    }
}
