//
//  main.swift
//  Dash
//
//  Created by Ta-Seen Islam on 16/10/19.
//  Copyright © 2019 Ta-Seen Islam. All rights reserved.
//

import Foundation

let expr = BinaryExpr(
    left: UnaryExpr(withOperator: Token(withType: .char(.minus),
                                        lexeme: "-",
                                        literal: nil,
                                        line: 1),
                    rightExpr: LiteralExpr(withValue: 123)),
    operator: Token(withType: .char(.asterisk),
                    lexeme: "*",
                    literal: nil,
                    line: 1),
    right: GroupingExpr(withExpression: LiteralExpr(withValue: 45.67)))

print(AstPrinter().print(expr: expr))

do {
    try Dash.startInterpreter(withArgs: Array(CommandLine.arguments[1...]))
} catch {
    print("\u{001B}[1;31mOops, an error occurred!\u{001B}[0;0m")
    print(error.localizedDescription)
//    print("Usage: `dash [[-f | --file] <path-to-script>]`, where brackets ('[' and ']') indicate optional arguments")
    exit(EXIT_FAILURE)
}
