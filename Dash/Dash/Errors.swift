//
//  Errors.swift
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

extension SysArgsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidNumberOfArgs(let expected, let given, let helpMessage):
            let errorMessage = "Invalid number of arguments: expected \(expected), found \(given)"
            return self.constructMessage(error: errorMessage, help: helpMessage)
        case .unknownArg(let arg):
            let errorMessage = "Unknown argument `\(arg)`"
            return self.constructMessage(error: errorMessage)
        }
    }
    
    private func constructMessage(error message: String, help: String? = nil) -> String {
        let msg = "\u{001B}[1;31m  [error]:\u{001B}[0;0m \(message)"
        if let help = help {
            return msg + "\n\u{001B}[1;34m   [help]:\u{001B}[0;0m \(help)"
        } else {
            return msg
        }
    }
}
