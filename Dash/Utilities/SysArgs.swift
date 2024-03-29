//
//  SysArgs.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

enum SysArgsError: Error {
    case invalidNumberOfArgs(Int, Int, String? = nil)
    case unknownArg(String)
}

enum InputSource {
    case stdin
    case file(path: String)
}

class SysArgs {
    var inputSource: InputSource = .stdin
    
    init?(parse args: [String]) throws {
        func getArgumentsForParameter(atIndex index: Int, help msg: String) throws -> String {
            guard !(index == (args.endIndex - 1)) && !(args[index + 1].starts(with: "-")) else {
                throw SysArgsError.invalidNumberOfArgs(1, 0, msg)
            }
            
            return args[index + 1]
        }
        
        for (i, arg) in args.enumerated() {
            if arg.starts(with: "-") {
                switch arg {
                case "-f", "--file":
                    let helpMessage = "Parameter 'file' (with `-f` or `--file`) requires a path to the Dash script"
                    self.inputSource = .file(path: try getArgumentsForParameter(atIndex: i, help: helpMessage))
                case "-r", "--read":
                    self.inputSource = .stdin
                default:
                    throw SysArgsError.unknownArg(arg)
                }
            } else {
                self.inputSource = .file(path: arg)
            }
        }
    }
}
