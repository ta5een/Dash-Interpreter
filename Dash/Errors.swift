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
        let msg = "\t[error]:\t\(message)"
        if let help = help {
            return msg + "\n\t [help]:\t\(help)"
        } else {
            return msg
        }
    }
}
