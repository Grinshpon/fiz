{
  open Lexing
  open Parser

  exception SyntaxError of string
}

let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']*
let operator = [ '+' '-' '*' '/' '^' '=' '!' '#' '$' '<' '>' ':' '|' '\\']+

let digit = ['0'-'9']
let int = '-'? digit+
let frac = '.' digit*
let float = '-'? digit* frac

let bool = "true" | "false"

let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n" | "\n\r"

rule token = parse
  | whitespace
    { token lexbuf }
  | newline
    { new_line lexbuf; token lexbuf }
  | "def" { DEF }
  | "let" { LET }
  | "in" { IN }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "match" { MATCH }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | '|' { GUARD }
  | ":=" { ASSIGN }
  | '\\' { LAMBDA }
  | "->" { ARROW }
  | ";;" { DSEMI }
  | ';' { SEMI }
  | float as n
    { FLOAT (float_of_string(n)) }
  | int as n
    { INT (int_of_string(n)) }
  | bool as b
    { BOOL (bool_of_string(b)) }
  | ident as id
    { IDENT id }
  | operator as o
    { OP o }
  | eof { EOF }
