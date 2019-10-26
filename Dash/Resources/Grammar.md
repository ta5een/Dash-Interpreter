# Dash Grammar

```
program        → declaration* EOF ;

declaration    → varDecl
               | statement ;
statement      → exprStmt
               | printStmt ;
               
varDecl        → "var" IDENTIFIER ( "=" expression )? ";" ;

exprStmt       → expression (";" | "\n") ;
printStmt      → "print" expression (";"| "\n") ;

expression     → assignment ;
assignment     → IDENTIFIER "=" assignment
               | equality ;
equality       → comparison ( ( "!=" | "==" ) comparison )* ;
comparison     → addition ( ( ">" | ">=" | "<" | "<=" ) addition )* ;
addition       → multiplication ( ( "-" | "+" ) multiplication )* ;
multiplication → unary ( ( "/" | "*" ) unary )* ;
unary          → ( "!" | "-" ) unary
               | primary ;
primary        → "true" | "false" | "nil"
               | NUMBER | STRING
               | "(" expression ")"
               | IDENTIFIER ;
```
