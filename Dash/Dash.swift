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
    let char: Int?
    
    var description: String {
        if let char = self.char {
            return "line \(self.line), character: \(char) (\(self.line):\(char))"
        } else {
            return "line \(self.line)"
        }
    }
}

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
                    print("\u{001B}[1;36mInput source: REPL\u{001B}[0;0m")
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
        
        do {
            let statements = try parser.parse()
            self.interpreter.interpret(statements: statements)
        } catch {
            Dash.reportError(location: nil, message: "Failed to parse input.")
            self.errorFound = true
        }
        
        if self.errorFound { return }
    }
    
    static func reportError(location: ErrorLocation?, message: String, help: String? = nil) {
        print(self.constructErrorMessage(location: location, message: message, help: help))
        self.errorFound = true
    }
    
    static func reportRuntimeError(error: RuntimeError) {
        switch error {
        case .invalidOperand(token: let token, message: let message, help: let help):
            print(self.constructErrorMessage(location: ErrorLocation(line: token.line, char: nil),
                                        message: message,
                                        help: help))
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
                \(b)     at:\(x) \(location.description)
                \(b)   help:\(x) \(help)
                """
            } else {
                return """
                \(r)  error:\(x) \(message)
                \(b)     at:\(x) \(location.description)
                """
            }
        }
        
        return """
        \(r)  error:\(x) \(message)
        """
    }
}
