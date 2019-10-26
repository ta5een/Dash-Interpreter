//
//  Environment.swift
//  Dash
//
//  Created by Ta-Seen Islam on 26/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class Environment {
    private var values: [String: Any?] = [:]
    
    func define(name: String, withValue value: Any?) {
        self.values[name] = value
    }
    
    func getValue(withName name: Token) throws -> Any? {
        if let value = self.values[name.lexeme] {
            return value
        }
        
        throw RuntimeError.undefinedVariable(token: name)
    }
}
