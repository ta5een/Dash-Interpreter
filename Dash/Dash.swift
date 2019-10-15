//
//  Dash.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

class Dash {
    
    static var errorFound: Bool = false
    
    static func startInterpreter(withArgs args: [String]) throws {
        if args.isEmpty {
            self.runPrompt()
        } else {
            let sysArgs = try SysArgs(parse: args)
            print("Input source: \(sysArgs!.inputSource)")
        }
    }
    
    static func runFile(fromPath path: String) {
        if let dir = FileManager.default.urls(for: .userDirectory, in: .userDomainMask).first {
            let url = dir.appendingPathComponent(path)
            do {
                self.run(fromSource: try String(contentsOf: url, encoding: .utf8))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static func runPrompt() {
        print("Dash REPL v0.1")
        
        while true {
            print("> ", terminator: "")
            if let readLine = readLine() {
                self.run(fromSource: readLine)
            } else {
                print("{EOF}")
                print("Exiting...")
                break
            }
        }
    }
    
    private static func run(fromSource source: String) {
        print(source)
    }
    
    private static func reportError(location: String, message: String) {
        print("[\(location)] Error: \(message)")
        self.errorFound = true
    }
    
}
