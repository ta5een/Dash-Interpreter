//
//  Errors.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

private func constructMessage(error message: String, help: String? = nil) -> String {
    let msg = "\u{001B}[1;31m  [error]:\u{001B}[0;0m \(message)"
    if let help = help {
        return msg + "\n\u{001B}[1;34m   [help]:\u{001B}[0;0m \(help)"
    } else {
        return msg
    }
}

extension SysArgsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidNumberOfArgs(let expected, let given, let helpMessage):
            let errorMessage = "Invalid number of arguments: expected \(expected), found \(given)"
            return constructMessage(error: errorMessage, help: helpMessage)
        case .unknownArg(let arg):
            let errorMessage = "Unknown argument `\(arg)`"
            return constructMessage(error: errorMessage)
        }
    }
}

extension ParseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .parseError(token: let token, message: let errorMessage):
            if token.type == .eof {
                return constructMessage(error: "line \(token.line) at end: \(errorMessage)")
            } else {
                return constructMessage(error: "line \(token.line) on `\(token.lexeme)`: \(errorMessage)")
            }
        }
    }
}

extension RuntimeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidOperand(expected: let expected):
            return constructMessage(error: "Operand must be a \(expected)")
        }
    }
}
