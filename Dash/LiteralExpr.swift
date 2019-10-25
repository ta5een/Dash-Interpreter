//
//  LiteralExpr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

typealias LiteralExprValue = CustomStringConvertible

class LiteralExpr: Expr {
    let value: LiteralExprValue?
    
    init(withValue value: LiteralExprValue?) {
        self.value = value
    }
    
    func accept<V: ExprVisitor, R>(visitor: V) throws -> R where V.R == R {
        return try visitor.visitLiteralExpr(expr: self)
    }
}

extension LiteralExpr: CustomStringConvertible {
    var description: String {
        if let value = self.value {
            return value.description
        } else {
            return "nothing"
        }
    }
}
