//
//  Dash.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class Dash {
    static let interpreter: Interpreter = Interpreter()
    static var errorFound: Bool = false
    static var hadRuntimeError: Bool = false
    
    static func startInterpreter(withArgs args: [String]) throws {
        if args.isEmpty {
            self.runPrompt()
        } else {
            let sysArgs = try SysArgs(parse: args)
            
            if let inputSource = sysArgs?.inputSource {
                switch inputSource {
                case .stdin:
                    self.runPrompt()
                case .file(let path):
                    print("\u{001B}[1;36mInput source: \(inputSource)\u{001B}[0;0m")
                    self.runFile(fromPath: path)
                }
            }
        }
    }
    
    static func runFile(fromPath path: String) {
        let url = URL(fileURLWithPath: path)
        do {
            self.run(fromSource: try String(contentsOf: url, encoding: .utf8))
        } catch {
            print(error.localizedDescription)
        }
        
        if self.errorFound { exit(EXIT_FAILURE) }
        if self.hadRuntimeError { exit(EXIT_FAILURE) }
    }
    
    static func runPrompt() {
        print("Dash REPL v0.1")
        
        while true {
            print("\n> ", terminator: "")
            if let readLine = readLine() {
                guard readLine != ":exit" else {
                    print("\nExiting...")
                    break
                }
                
                self.errorFound = false
                self.run(fromSource: readLine)
            } else {
                print("\u{001B}[1;30m{EOF}\u{001B}[0;0m")
                print("\nExiting...")
                break
            }
        }
    }
    
    private static func run(fromSource source: String) {
        let tokens = Scanner(fromSource: source).scanTokens()
        let parser = Parser(withTokens: tokens)
        
        if self.errorFound { return }
        
        if let expr = parser.parse() {
            do {
                print(": ", terminator: "")
                try print(AstPrinter().print(expr: expr))
                self.interpreter.interpret(expression: expr)
            } catch {
                print("An error occurred: \(error.localizedDescription)")
            }
        } else {
            Dash.reportError(location: (0, 0), message: "Failed to parse expression")
        }
    }
    
    static func reportError(location: (Int, Int), message: String) {
        print("\u{001B}[1;31m[\(location.0):\(location.1)] Error: \(message)\u{001B}[0;0m")
        
        self.errorFound = true
    }
    
    static func reportRuntimeError(error: RuntimeError) {
        switch error {
        case .invalidOperand(token: let token, message: let message):
            print("\u{001B}[1;31m[\(token.line)] Error: \(message)\u{001B}[0;0m")
        }
        
        self.hadRuntimeError = true
    }
}
