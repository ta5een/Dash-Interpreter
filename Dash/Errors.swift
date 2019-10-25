//
//  Errors.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

extension SysArgsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidNumberOfArgs(let expected, let given, let helpMessage):
            let errorMessage = "Invalid number of arguments: expected \(expected), found \(given)"
            return Dash.constructErrorMessage(location: nil,
                                              message: errorMessage,
                                              help: helpMessage)
        case .unknownArg(let arg):
            let errorMessage = "Unknown argument `\(arg)`"
            return Dash.constructErrorMessage(location: nil, message: errorMessage)
        }
    }
}

extension ParseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .parseError(token: let token, message: let errorMessage):
            if token.type == .eof {
                return Dash.constructErrorMessage(location: ErrorLocation(line: token.line, column: nil),
                                                  message: errorMessage,
                                                  help: nil)
            } else {
                return Dash.constructErrorMessage(location: ErrorLocation(line: token.line, column: nil),
                                                  message: errorMessage,
                                                  help: "Unknown token `\(token.lexeme)`.")
            }
        }
    }
}

extension RuntimeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidOperand(token: let token, message: let message, help: let help):
            return Dash.constructErrorMessage(location: ErrorLocation(line: token.line, column: nil),
                                              message: message,
                                              help: help)
        }
    }
}
