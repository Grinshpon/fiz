{
  open Lexing
  open Parser

  exception SyntaxError of string
}

let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' ]* [ '\'' ]*


let operator_rest = [ '+' '-' '*' '/' '^' '=' '!' '#' '$' '<' '>' ':' '|' '~' '\\']+
let prefix_op = [ '~' '!' ] operator_rest*
let infix_op0 = ['=' '<' '>' '|' '&' '$'] operator_rest*
let infix_op1 = ['@' '^' ':'] operator_rest*
let infix_op2 = ['+' '-'] operator_rest*
let infix_op3 = ['*' '/' '%' '#'] operator_rest*
let infix_op4 = "**" operator_rest*

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
  | "--"
    { comment lexbuf }
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
  | '[' { LBRACKET }
  | ']' { RBRACKET }
  | ',' { COMMA }
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
  | "&&"
    { AND }
  | "||"
    { OR }
  | "~=" as i
    { INFIXOP0 i }
  | infix_op0 as i
    { INFIXOP0 i }
  | infix_op1 as i
    { INFIXOP1 i }
  | infix_op2 as i
    { INFIXOP2 i }
  | infix_op4 as i
    { INFIXOP4 i }
  | infix_op3 as i
    { INFIXOP3 i }
  | prefix_op as p
    { PREFIXOP p }
  | eof { EOF }

and comment = parse
  | newline
    { new_line lexbuf; token lexbuf }
  | eof
    { EOF }
  | _
    { comment lexbuf }
