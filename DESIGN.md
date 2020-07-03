## Design (WIP)

The grammar can be seen by looking at the Ast module and the parser. I'll write it out, for now it's basically notes.

A .fiz file describes a fiz module, and each fiz module is a series of definitions. Modules are essentially namespaces, a file is a module taking it's name (so importing mod.fiz will give you a module named mod and you can access it's definitions using mod.name). You can also have local modules in a file that act as local namespaces. Also, in any project, there must be a main module containing a main function. 

NOTE: All the examples below have operators done in infix notation. Currently all operators are prefixed. This may or may not change, and I will update the document accordingly once I settle on a definitive decision.

Top level definitions are made with the `def` keyword. Assignment is done using the operator `:=`. `=` and `==` are synonyms and are used for comparison.

    def val := 1;;

Functions are defined the same way. Functions are first class and treated like values.

    def foo x := x + 5;;

Fiz does not use whitespace as part of the grammar (like languages such as haskell or python do), and so each definition is separated by a double semicolon:

    def y := 5;; def x := 6;;

Lambda functions are defined with `\ ... -> ...`.

    def foo := \x -> x + 5;;

Lists are delineated by square brackets `[a,b,...,z]`

    def myList := [1,2,3];;

    def myElem := myList # 1; // `#` is a function that retrieves the element at a given index.

`match` is a builtin that provides pattern matching. `{..}` is a chunk.

    def myIf c t f := match c {
      True -> t;
      False -> f;
    };;

    def bar x y := match x {
      5  -> "five"; //x matches with 5
      @y -> "eq"; //experimental: x matches with the value of the existing variable y
      y  -> "x is" ++ (show y); //x is bound to a new variable y, which overshadows the argument
    };;

`let ... in ...` is another builtin that lets you define local immutable variables to use.

    def baz x := let y := x + 5 in y;;

    def positiveSum x y :=
      let
        x' := max x 0;
        y' := max y 0;
      in x' + y';;

functions are pure unless operating in an io context. I don't know what io or monad situation will look like exactly.

`do {..}` is an io block where you can write side-effectful code, allowing you to use locally scoped mutable variables `var x := 1; set x := x + 1`

    def main := do {
      var x := 2;
      print (bar 1 x);
      set x := x+1;
      print (bar 3 x);
    };;

Custom types are defined with `type T := ...`.

    //Sum types
    type Bool := True | False;
    type Maybe a := Some a | None;

    //Product type
    type MyType := MyType Int Int;

    //Record type
    type Person := {
      age: Int;
      name: String;
    };;
    // record access is done with the dot operator (ex: person.age)

Modules are made with the `module` keyword.

    module Inner := {
      def innerVal := ...;
    };;

If a module does not specify what is is exporting, it is assumed to be exporting everything. Otherwise, `export` will state what is public and what is private. If a module has an `export`, it must be the first expression.

    //mymod.fiz
    export {
      val1;
      fn1;
      Inner;
    };;
    def val1 := ...;;
    def val2 := ...;;
    def fn1 x := ...;;
    def fn2 := ...;;
    module Inner := { ... };;

An alias is essentially text substitution. Any type (and maybe even keywords) can be aliased.

    alias Age := Int;;

### Style

Fiz uses camelCase for variable and function names, and PascalCase for types and modules. This is enforced by the compiler. File names are lowercase.

### Experimental

This section contains designs of the language that I'm less comfortable with or considering having or not having.

Funcions might have statement-like forms by prefacing additional keywords with `'` (or some other symbol)

    def myIf cond 'myThen f 'myElse g := if cond then f else g;;

    def isOne x := myIf x = 1 myThen "is one" myElse "is not one";;


Fiz will be statically typed, but types do not need to be specified most of the time, that's handled by type inference. (WIP) Types may be annotated with `:`

    def foo x: Int -> Int := x + (5: Int);;

    //NOTE: alternate potential syntax for type annotations:
      def foo (x: Int): Int := x + (5: Int);;

Type classes? I'm not sure about this, but type classes could be defined with the `class` keyword.

    class MyNum a := {
      (+.) : a -> a -> a;
      (-.) : a -> a -> a;
      (*.) : a -> a -> a;
      (/.) : a -> a -> a;
      sign : a -> Int;
    };;

And then type class instances are defined via `instance Class T := {...}`?

    instance MyNum Int := {
      x +. y := x+y;
      //...
    };;

The reason I'm skeptical about having type classes is because it will increase the complexity of the language (which is meant to be kept rather simple) and it will make type inference much harder. Essentially, it will require the programmer to write explicit type signatures a lot more. Now that isn't a bad thing at all, in fact it's a good thing for anyone that values type safety (so anyone familiar with functional programming), but in this case it's not desired because, as stated previously, this is meant to be a simple langauge to play around with.

Another thing to consider is whether or not to have lazy evaluation.

## Compiler Ideas

One idea is to target LuaJIT by transpiling to Lua or generating LuaJIT bytecode directly.

A better idea is to target the [GRIN compiler framework](https://github.com/grin-compiler/grin)
