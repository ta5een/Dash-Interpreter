//
//  main.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

do {
    try Dash.startInterpreter(withArgs: Array(CommandLine.arguments[1...]))
} catch {
    print("Oops, an error occurred!")
    print(error.localizedDescription)
//    print("Usage: `dash [[-f | --file] <path-to-script>]`, where brackets ('[' and ']') indicate optional arguments")
    exit(EXIT_FAILURE)
}
