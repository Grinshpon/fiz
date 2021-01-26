open Ast

type ty =
  | TUnit
  | TInt
  | TFloat
  | TBool
  | TFunc of ty list
  | TList of ty
  | TUser of ident (* user defined type (placeholder) *)

let match_ty = function
  | "Unit" -> TUnit
  | "Int" -> TInt
  | "Float" -> TFloat
  | "TBool" -> TBool
  | t -> TUser(t)

let rec pp_ty ppf = let open Format in function
  | TUnit -> fprintf ppf "Unit";
  | TInt -> fprintf ppf "Int";
  | TFloat -> fprintf ppf "Float";
  | TBool -> fprintf ppf "Bool";
  | TFunc (t::ts) -> pp_ty ppf t; begin match ts with
    | [] -> fprintf ppf "";
    | [lt] -> fprintf ppf " -> "; pp_ty ppf lt;
    | lst -> fprintf ppf " -> "; pp_ty ppf (TFunc lst);
    end
  | TFunc [] -> fprintf ppf "IMPOSSIBLE";
  | TList t -> fprintf ppf "List "; pp_ty ppf t;
  | TUser t -> fprintf ppf "%s" t;


