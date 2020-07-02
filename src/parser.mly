%token DEF
%token LET IN
%token IF THEN ELSE
%token LPAREN RPAREN
%token ASSIGN (* := *) LAMBDA (* \ *) ARROW (* -> *)
%token SEMI DSEMI
%token <float> FLOAT
%token <int> INT
%token <string> IDENT
%token <string> OP
%token <bool> BOOL
%token EOF

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
  | a = app_expr
    { a }
  ;

app_expr:
  | e = plain_expr
    { e }
  | f = app_expr e = args
    { `App(f,e) }
  ;

plain_expr:
  | LPAREN e = expr RPAREN
    { e }
  | o = OP (* for now operators are prefix *)
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
