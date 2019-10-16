//
//  Expr.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class Expr {}

class Binary: Expr {
    
    let left: Expr
    let `operator`: Token
    let right: Expr
    
    init(left: Expr, operator: Token, right: Expr) {
        self.left = left
        self.operator = `operator`
        self.right = right
    }
    
}
