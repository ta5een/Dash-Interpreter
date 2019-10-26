//
//  Environment.swift
//  Dash
//
//  Created by Ta-Seen Islam on 26/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class Environment {
    var enclosing: Environment?
    private var values: [String: Any?] = [:]
    
    init(withEnclosingEnvironment enclosing: Environment? = nil) {
        self.enclosing = enclosing
    }
    
    func define(name: String, withValue value: Any?) {
        self.values[name] = value
    }
    
    func assign(name: Token, withValue value: Any?) throws {
        if let _ = self.values[name.lexeme] {
            self.values[name.lexeme] = value
            return
        }
        
        if let enclosing = self.enclosing {
            try enclosing.assign(name: name, withValue: value)
            return
        }
        
        throw RuntimeError.undefinedVariable(token: name)
    }
    
    func getValue(withName name: Token) throws -> Any? {
        if let value = self.values[name.lexeme] {
            return value
        }
        
        if let enclosing = self.enclosing {
            return try enclosing.getValue(withName: name)
        }
        
        throw RuntimeError.undefinedVariable(token: name)
    }
}
