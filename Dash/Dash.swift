//
//  Dash.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

struct ErrorLocation: CustomStringConvertible {
    let line: Int
    let column: Int?
    
    var description: String {
        if let column = self.column {
            return "line \(self.line), column \(column) (\(self.line):\(column))"
        } else {
            return "line \(self.line)"
        }
    }
}

class Dash {
    static let interpreter: Interpreter = Interpreter()
    static var errorFound: Bool = false
    static var hadRuntimeError: Bool = false
    static var inRepl: Bool = true
    
    static func startInterpreter(withArgs args: [String]) throws {
        if args.isEmpty {
            self.runPrompt()
        } else {
            let sysArgs = try SysArgs(parse: args)
            
            if let inputSource = sysArgs?.inputSource {
                switch inputSource {
                case .stdin:
                    self.inRepl = true
                    self.runPrompt()
                case .file(let path):
                    self.inRepl = false
                    self.runFile(fromPath: path)
                }
            }
        }
    }
    
    static func runFile(fromPath path: String) {
        print("\u{001B}[1;36mInput source: \(InputSource.file(path: path))\u{001B}[0;0m")
        
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
        print("\u{001B}[1;36mInput source: \(InputSource.stdin)\u{001B}[0;0m")
        print("Dash REPL v0.1")
        
        while true {
            print("> ", terminator: "")
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
        
        do {
            let statements = try parser.parse()
            self.interpreter.interpret(statements: statements)
        } catch {
            print(error.localizedDescription)
            self.errorFound = true
        }
        
        if self.errorFound { return }
    }
    
    static func logMessage(file: String? = nil, function: String? = nil, line: Int? = nil, message: String) {
        let escapeSeq = "\u{001B}"
        let b = "\(escapeSeq)[1;34m"    // blue
        let x = "\(escapeSeq)[0;0m"     // reset/none
        
        let log: (String?) -> String = { location in
            return """
            \(b)    log:\(x) \(message)
            \(b)  where:\(x) \(location ?? "")
            
            """
        }
        
        switch (file, function, line) {
        case (.some(let file), .some(let function), .some(let line)):
            print(log("\(file).\(function), line \(line)"))
        case (.some(let file), .some(let function), .none):
            print(log("\(file).\(function)"))
        case (.some(let file), .none, .none):
            print(log("\(file)"))
        default:
            print(log(nil))
        }
    }
    
    static func reportError(location: ErrorLocation?, message: String, help: String? = nil) {
        print(self.constructErrorMessage(location: location, message: message, help: help))
        self.errorFound = true
    }
    
    static func reportRuntimeError(error: RuntimeError) {
        switch error {
        case .invalidOperand(token: let token, message: let message, help: let help):
            let message = self.constructErrorMessage(
                location: ErrorLocation(line: token.line, column: token.column),
                message: message,
                help: help
            )
            print(message)
        case .undefinedVariable(token: let token):
            let message = self.constructErrorMessage(
                location: ErrorLocation(line: token.line, column: token.column),
                message: "Undefined variable `\(token.lexeme)`.",
                help: "The variable named `\(token.lexeme)` could not be found in the current scope."
            )
            print(message)
        }
        
        self.hadRuntimeError = true
    }
    
    static func constructErrorMessage(location: ErrorLocation?, message: String, help: String? = nil) -> String {
        let escapeSeq = "\u{001B}"
        let r = "\(escapeSeq)[1;31m"    // red
        let b = "\(escapeSeq)[1;34m"    // blue
        let x = "\(escapeSeq)[0;0m"     // reset/none
        
        if let location = location {
            if let help = help {
                return """
                \(r)  error:\(x) \(message)
                \(b)  where:\(x) \(location.description)
                \(b)   help:\(x) \(help)
                
                """
            } else {
                return """
                \(r)  error:\(x) \(message)
                \(b)  where:\(x) \(location.description)
                
                """
            }
        }
        
        return """
        \(r)  error:\(x) \(message)
        
        """
    }
}
