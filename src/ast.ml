type ident = string
[@@deriving show]

type op = string
[@@deriving show]

type expr =
  | Lambda of (ident list) * expr (* multi argument lambda function (todo: use nanocaml to convert this AST to lambda calculus) *)
  | Let of (ident * expr) list * expr (* let ... in ... *)
  | If of expr * expr * expr
  | Match of expr * ((expr*expr) list)
  | Op of ident
  | App of expr * (expr list)
  | Ident of ident
  | Int of int
  | Float of float
  | Bool of bool
  | List of expr list
  | Type of ident
  | FnType of expr list
  | TCons of ident * expr
[@@deriving show]

type command =
  | LetTop of ident * expr
  | Expr of expr
  | Def of ident * expr (* make ident * ty or ident*expr *)
[@@deriving show]
