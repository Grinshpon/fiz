type ident = string
[@@deriving show]
type op = string
[@@deriving show]

type ty = [
  | `TInt
  | `TFloat
  | `TBool
  | `TFunc of ty list
  | `TList of ty
]

type expr = [
  | `Lambda of (ident list) * expr (* multi argument lambda function (todo: use nanocaml to convert this AST to lambda calculus) *)
  | `Let of (ident * expr) list * expr (* let ... in ... *)
  | `If of expr * expr * expr
  | `Match of expr * ((expr*expr) list)
  | `Op of ident
  | `App of expr * (expr list)
  | `Ident of ident
  | `Int of int
  | `Float of float
  | `Bool of bool
  | `List of expr list
][@@deriving show]

type command = [
  | `Def of ident * expr
  | `Expr of expr
][@@deriving show]

let rec pp_ty ppf = let open Format in function
  | `TInt -> fprintf ppf "Int";
  | `TFloat -> fprintf ppf "Float";
  | `TBool -> fprintf ppf "Bool";
  | `TFunc (t::ts) -> pp_ty ppf t; begin match ts with
    | [] -> fprintf ppf "";
    | [lt] -> fprintf ppf "->"; pp_ty ppf lt;
    | lst -> fprintf ppf "->"; pp_ty ppf (`TFunc lst);
    end
  | `TFunc [] -> fprintf ppf "IMPOSSIBLE"
