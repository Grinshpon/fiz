# Fiz

Fiz is a concept for toy programming language designed to be simple and minimal. It's meant for playing around with, and is mainly just an exercise in designing a toy programming language (for fun). It's not a competitor to other serious functional languages, because fiz is probably not a very good language. I just wanted to put my ideas down somewhere. I cannot stress enough how dumb all this probably is.

All the design/syntax is work in progress. Once I iterate a couple of times and lock down a grammar I like, I may begin writing a parser and then compiler.

## Design (WIP)

I'll create a formal grammar later, for now it's basically notes.

A .fiz file describes a fiz module, and each fiz module is a series of definitions. Modules are essentially namespaces, a file is a module taking it's name (so importing mod.fiz will give you a module named mod and you can access it's definitions using mod.name). You can also have local modules in a file that act as local namespaces. Also, in any project, there must be a main module containing a main function. 

Fiz does not use whitespace as part of the grammar (like languages such as haskell or python do), and so each definition is separated by a semicolon:

    y := 5;

Assignment is done using the operator `:=`. `=` and `==` are synonyms and are used for comparison.

Functions are defined the same way. Functions are first class and treated like values.

    foo x := x + 5;

Lambda functions are defined with `\ ... -> ...`.

    foo := \x -> x + 5;

Single line comments are made with `//` and multiline/block comments with `/* ... */`. Block comments can be nested. 

Fiz will be statically typed, but types do not need to be specified most of the time, that's handled by type inference. (WIP) Types can be annotated with `:`

    foo x: Int -> Int := (x: Int) + 5;

Lists are delineated by square brackets `[a,b,...,z]`

    myList := [1,2,3];
    
    myElem := myList # 1; // `#` is a function that retrieves the element at a given index.

`case` is a builtin that provides pattern matching. `{..}` is a chunk.

    myIf c t f := case c {
	    True -> t;
	    False -> f;
    };

    bar x y := case x {
	    5  -> "five"; //x matches with 5
	    @y -> "eq"; //x matches with the value of the existing variable y
	    y  -> "x is" ++ (show y); //x is bound to a new variable y, which overshadows the argument
    };

`let ... in ...` is another builtin that lets you define local immutable variables to use.

    baz x := let y := x + 5 in y;

    positiveSum x y :=
	    let
		    x' := max x 0;
		    y' := max y 0;
	    in x' + y';

functions are pure unless operating in an io context. I don't know what io or monad situation will look like exactly.

`do {..}` is an io block where you can write side-effectful code, allowing you to use locally scoped mutable variables `var x := 1; set x := x + 1`

    main := do {
	    var x := 2;
	    print (bar 1 x);
	    set x := x+1;
	    print (bar 3 x);
    };

Custom types are defined with `::=`

    Bool ::= True | False;

### Experimental

This section contains designs of the language that I'm less comfortable with or considering having or not having.

Funcions might have statement-like forms by prefacing additional keywords with `'` (or some other symbol)

    myIf cond 'myThen f 'myElse g := if cond then f else g;
    
    isOne x := myIf x = 1 myThen "is one" myElse "is not one";

Type classes? I'm not sure about this, but type classes could be defined within a `::{..}` block.

    MyNum a ::{
	    a +. a: a;
	    a -. a: a;
	    a *. a: a;
	    a /. a: a;
	    sign a: Int;
    };

And then type class instances are defined via `::= {..}`?

    MyNum Int ::= {
	    x +. y := x+y;
	    //...
    };
