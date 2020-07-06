%token DEF
%token LET IN
%token IF THEN ELSE
%token MATCH
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token ASSIGN (* := *) LAMBDA (* \ *) ARROW (* -> *) GUARD (* | *)
%token AND (* && *) OR (* || *)
%token SEMI DSEMI COMMA
%token <float> FLOAT
%token <int> INT
%token <string> IDENT
%token <string> PREFIXOP
%token <string> INFIXOP0
%token <string> INFIXOP1
%token <string> INFIXOP2
%token <string> INFIXOP3
%token <string> INFIXOP4
%token <bool> BOOL
%token EOF

/* Precedence/Associativity, pretty much taken from Ocaml parser:
 * https://github.com/ocaml/ocaml/blob/trunk/parsing/parser.mly
 */

%right ARROW
%right AND OR
%left  INFIXOP0
%right INFIXOP1
%left  INFIXOP2
%left  INFIXOP3
%right INFIXOP4
%nonassoc PREFIXOP


%start <Ast.command list> prog

%start <Ast.command option> toplevel
%%


prog:
  | EOF
    { [] }
  | d = def EOF
    { [d] }
  | d = def DSEMI lst = prog
    { d::lst }
  | e = expr EOF
    { [`Expr e] }
  | e = expr DSEMI lst = prog
    { (`Expr e)::lst }
  ;

toplevel:
  | d = def DSEMI
    { Some d }
  | e = expr DSEMI
    { Some (`Expr e) }
  | DSEMI
    { None }
  | EOF
    { None }
  ;

def:
  | DEF x = IDENT ASSIGN e = expr
    { `Def(x,e) }
  | DEF x = IDENT p = params ASSIGN e = expr
    { `Def(x, `Lambda(p,e)) } (* if expr is another lambda, have function to join them *)
  ;

expr:
  | LAMBDA a = params ARROW e = expr
    { `Lambda(a,e) }
  | LET l = letassign IN e = expr
    { `Let(l,e) }
  | IF c = expr THEN t = expr ELSE f = expr
    { `If(c,t,f) }
  | MATCH e = expr LBRACE c = cases RBRACE
    { `Match(e,c) }
  | a = app_expr
    { a }
  ;

cases:
  | GUARD? c = plain_expr ARROW e = expr SEMI GUARD cs = cases
    { (c,e)::cs }
  | c = plain_expr ARROW e = expr SEMI
    { [(c,e)] }
  ;


app_expr:
  | e = plain_expr
    { e }
  | op = op_expr
    { op }
  | f = app_expr e = args
    { `App(f,e) }
  ;

op_expr:
  | p = PREFIXOP e = plain_expr
    { `App((`Op p), [e]) }
  | e1 = app_expr op = infix_op e2 = app_expr
    { `App((`Op op),[e1;e2]) }
  ;


plain_expr:
  | LBRACKET l = list_expr RBRACKET
    { `List l }
  | LPAREN e = expr RPAREN
    { e }
  | LPAREN o = op_id RPAREN
    { `Op o }
  | id = IDENT
    { `Ident id }
  | n = INT
    { `Int n }
  | n = FLOAT
    { `Float n }
  | b = BOOL
    { `Bool b }
  ;

op_id:
  | p = PREFIXOP
    { p }
  | p = infix_op
    { p }

%inline infix_op:
  | AND
    { "&&" }
  | OR
    { "||" }
  | i = INFIXOP0
    { i }
  | i = INFIXOP1
    { i }
  | i = INFIXOP2
    { i }
  | i = INFIXOP3
    { i }
  | i = INFIXOP4
    { i }
  ;

list_expr:
  | e = expr COMMA lst = list_expr
    { e::lst }
  | e = expr COMMA?
    { [e] }
  ;

args:
  | e = plain_expr es = args
    { e::es }
  | e = plain_expr
    { [e] }
  ;

params:
  | e = IDENT
    { [e] }
  | e = IDENT es = params
    { e::es }
  ;

letassign:
  | id = IDENT ASSIGN e = expr SEMI lst = letassign
    { (id,e)::lst }
  | id = IDENT ASSIGN e = expr SEMI
    { [(id,e)] }
  | id = IDENT ASSIGN e = expr
    { [(id,e)] }
  ;

%%
