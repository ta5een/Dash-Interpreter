//
//  Interpreter.swift
//  Dash
//
//  Created by Ta-Seen Islam on 25/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

enum RuntimeError: Error {
    case invalidOperand(token: Token, message: String)
}

class Interpreter {
    public func interpret(expression: Expr) {
        do {
            let value = try self.evaluate(expr: expression)
            print("= " + self.stringify(object: value))
        } catch {
            Dash.reportRuntimeError(error: error as! RuntimeError)
        }
    }
    
    private func stringify(object: Any?) -> String {
        if let object = object {
            return String(describing: object)
        } else {
            return "nothing"
        }
    }
    
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

extension Interpreter : ExprVisitor {
    typealias R = Any?

    func visitBinaryExpr(expr: BinaryExpr) throws -> R {
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
                                              message: "Operands must be two numbers or two strings")
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

    func visitGroupingExpr(expr: GroupingExpr) throws -> R {
        return try self.evaluate(expr: expr.expression)
    }

    func visitLiteralExpr(expr: LiteralExpr) throws -> R {
        return expr.value
    }

    func visitUnaryExpr(expr: UnaryExpr) throws -> R {
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
}
