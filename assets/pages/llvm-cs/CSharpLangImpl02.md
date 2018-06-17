---
layout: page
permalink: /llvm-cs/en/CSharpLangImpl02/
title: "Kaleidoscope: Implementing a Language with LLVM in CSharp"
---

# 2. Kaleidoscope: Implementing a Parser and AST

## 2.1. Chapter 2 Introduction

Welcome to Chapter 2 of the "[Implementing a language with LLVM](../)" tutorial. This chapter shows you how to use the lexer, built in [Chapter 1](../CSharpLangImpl01/), to build a full [parser](http://en.wikipedia.org/wiki/Parsing) for our Kaleidoscope language.
Once we have a parser, we'll define and build an Abstract Syntax Tree (AST).

The parser we will build uses a combination of
[Recursive Descent Parsing](http://en.wikipedia.org/wiki/Recursive_descent_parser) and
[Operator-Precedence Parsing](http://en.wikipedia.org/wiki/Operator-precedence_parser)
to parse the Kaleidoscope language (the latter for binary expressions and the former for everything else).
Before we get to parsing though, lets talk about the output of the parser: the
[Abstract Syntax Tree](http://en.wikipedia.org/wiki/Abstract_syntax_tree).

## 2.2. The Abstract Syntax Tree (AST)

The AST for a program captures its behavior in such a way that it is easy for later stages of the compiler (e.g. code generation) to interpret.
We basically want one object for each construct in the language, and the AST should closely model the language.
In Kaleidoscope, we have expressions, a prototype, and a function object. We'll start with expressions first:

```c#
namespace Kaleidoscope.AST
{
  public abstract class ExprAST
  {
    public abstract ExprType NodeType { get; protected set; }

    protected internal virtual ExprAST VisitChildren(ExprVisitor visitor)
    {
      return visitor.Visit(this);
    }

    protected internal virtual ExprAST Accept(ExprVisitor visitor)
    {
      return visitor.VisitExtension(this);
    }
  }

  public sealed class NumberExprAST : ExprAST
  {
    public NumberExprAST(double value)
    {
      this.Value = value;
      this.NodeType = ExprType.NumberExpr;
    }

    public double Value { get; private set; }

    public override ExprType NodeType { get; protected set; }

    protected internal override ExprAST Accept(ExprVisitor visitor)
    {
      return visitor.VisitNumberExprAST(this);
    }
  }
}
```

The code above shows the definition of the base `ExprAST` class and one subclass which we use for numeric literals.
The important thing to note about this code is that the `NumberExprAST` class captures the numeric value of the literal as an instance variable.
This allows later phases of the compiler to know what the stored numeric value is.

Right now we only create the AST, so there are no useful accessor methods on them.
It would be very easy to add a virtual method to pretty print the code, for example.
Here are the other expression AST node definitions that we'll use in the basic form of the Kaleidoscope language:

```c#
namespace Kaleidoscope.AST
{
  public sealed class VariableExprAST : ExprAST
  {
    public VariableExprAST(string name)
    {
      this.Name = name;
      this.NodeType = ExprType.VariableExpr;
    }

    public string Name { get; private set; }

    public override ExprType NodeType { get; protected set; }

    protected internal override ExprAST Accept(ExprVisitor visitor)
    {
      return visitor.VisitVariableExprAST(this);
    }
  }

  using System;
  public sealed class BinaryExprAST : ExprAST
  {
    public BinaryExprAST(char op, ExprAST lhs, ExprAST rhs)
    {
      switch (op)
      {
      case '+':
          this.NodeType = ExprType.AddExpr;
          break;
      case '-':
          this.NodeType = ExprType.SubtractExpr;
          break;
      case '*':
          this.NodeType = ExprType.MultiplyExpr;
          break;
      case '<':
          this.NodeType = ExprType.LessThanExpr;
          break;
      default:
          throw new ArgumentException("op " + op + " is not a valid operator");
      }

      this.Lhs = lhs;
      this.Rhs = rhs;
    }

    public ExprAST Lhs { get; private set; }

    public ExprAST Rhs { get; private set; }

    public override ExprType NodeType { get; protected set; }

    protected internal override ExprAST Accept(ExprVisitor visitor)
    {
      return visitor.VisitBinaryExprAST(this);
    }
  }

  using System.Collections.Generic;
  public sealed class CallExprAST : ExprAST
  {
    public CallExprAST(string callee, List<ExprAST> args)
    {
      this.Callee = callee;
      this.Arguments = args;
      this.NodeType = ExprType.CallExpr;
    }

    public string Callee { get; private set; }

    public List<ExprAST> Arguments { get; private set; }

    public override ExprType NodeType { get; protected set; }

    protected internal override ExprAST Accept(ExprVisitor visitor)
    {
      return visitor.VisitCallExprAST(this);
    }
  }
}
```

This is all (intentionally) rather straight-forward: variables capture the variable name, binary operators capture their opcode (e.g. `+`), and calls capture a function name as well as a list of any argument expressions.
One thing that is nice about our AST is that it captures the language features without talking about the syntax of the language.
Note that there is no discussion about precedence of binary operators, lexical structure, etc.

For our basic language, these are all of the expression nodes we'll define.
Because it doesn't have conditional control flow, it isn't Turing-complete;
we'll fix that in a later installment.
The two things we need next are a way to talk about the interface to a function, and a way to talk about functions themselves:

```c#
namespace Kaleidoscope.AST
{
  using System.Collections.Generic;
  public sealed class PrototypeAST : ExprAST
  {
    public PrototypeAST(string name, List<string> args)
    {
      this.Name = name;
      this.Arguments = args;
      this.NodeType = ExprType.PrototypeExpr;
    }

    public string Name { get; private set; }

    public List<string> Arguments { get; private set; }

    public override ExprType NodeType { get; protected set; }

    protected internal override ExprAST Accept(ExprVisitor visitor)
    {
      return visitor.VisitPrototypeAST(this);
    }
  }

  public sealed class FunctionAST : ExprAST
  {
    public FunctionAST(PrototypeAST proto, ExprAST body)
    {
      this.Proto = proto;
      this.Body = body;
      this.NodeType = ExprType.FunctionExpr;
    }

    public PrototypeAST Proto { get; private set; }

    public ExprAST Body { get; private set; }

    public override ExprType NodeType { get; protected set; }

    protected internal override ExprAST Accept(ExprVisitor visitor)
    {
      return visitor.VisitFunctionAST(this);
    }
  }
}
```

In Kaleidoscope, functions are typed with just a count of their arguments. Since all values are double precision floating point, the type of each argument doesn't need to be stored anywhere.
In a more aggressive and realistic language, the `ExprAST` class would probably have a type field.

With this scaffolding, we can now talk about parsing expressions and function bodies in Kaleidoscope.

## 2.3. Parser Basics

Now that we have an AST to build, we need to define the parser code to build it. The idea here is that we want to parse something like `x+y` (which is returned as three tokens by the lexer) into an AST that could be generated with calls like this:

```c#
var LHS = new VariableExprAST("x");
var RHS = new VariableExprAST("y");
var Result = new BinaryExprAST('+', LHS, RHS);
```

In order to do this, we'll start by defining some basic helper routines:

```c#
/// CurrentToken/GetNextToken - Provide a simple token buffer.  CurrentToken is the current
/// token the parser is looking at.  GetNextToken reads another token from the
/// lexer and updates CurrentToken with its results.

int CurrentToken;
int GetNextToken()
{
  return CurrentToken = GetNextTokenImpl();
}
```

This implements a simple token buffer around the lexer.
This allows us to look one token ahead at what the lexer is returning.
Every function in our parser will assume that `CurrentToken` is the current token that needs to be parsed.

<!--
```c++
/// LogError* - These are little helper functions for error handling.
std::unique_ptr<ExprAST> LogError(const char *Str) {
  fprintf(stderr, "LogError: %s\n", Str);
  return nullptr;
}
std::unique_ptr<PrototypeAST> LogErrorP(const char *Str) {
  LogError(Str);
  return nullptr;
}
```

The LogError routines are simple helper routines that our parser will use to handle errors. The error recovery in our parser will not be the best and is not particular user-friendly, but it will be enough for our tutorial. These routines make it easier to handle errors in routines that have various return types: they always return null.
-->

With these basic helper functions, we can implement the first piece of our grammar: numeric literals.

## 2.4. Basic Expression Parsing

We start with numeric literals, because they are the simplest to process.
For each production in our grammar, we'll define a function which parses that production.
For numeric literals, we have:

```c#
// numberexpr ::= number
private ExprAST ParseNumberExpr()
{
  ExprAST result = new NumberExprAST(this.scanner.GetLastNumber());
  this.scanner.GetNextToken();
  return result;
}
```

This routine is very simple: it expects to be called when the current token is a `Token.NUMBER` token. It takes the current number value, creates a `NumberExprAST` node, advances the lexer to the next token, and finally returns.

There are some interesting aspects to this.
The most important one is that this routine eats all of the tokens that correspond to the production and returns the lexer buffer with the next token (which is not part of the grammar production) ready to go.
This is a fairly standard way to go for recursive descent parsers.
For a better example, the parenthesis operator is defined like this:

```c#
// parenexpr ::= '(' expression ')'
private ExprAST ParseParenExpr()
{
  this.scanner.GetNextToken();  // eat (.
  ExprAST v = this.ParseExpression();
  if (v == null)
  {
    return null;
  }

  if (this.scanner.CurrentToken != ')')
  {
    Console.WriteLine("expected ')'");
    return null;
  }

  this.scanner.GetNextToken(); // eat ).

  return v;
}
```

This function illustrates a number of interesting things about the parser:

0. It shows how we log errors. When called, this function expects that the current token is a `(` token, but after parsing the subexpression, it is possible that there is no `)` waiting. For example, if the user types in `(4 x` instead of `(4)`, the parser should emit an error.
Because errors can occur, the parser needs a way to indicate that they happened: in our parser, we return null on an error.
0. Another interesting aspect of this function is that it uses recursion by calling `ParseExpression` (we will soon see that `ParseExpression` can call `ParseParenExpr`).
This is powerful because it allows us to handle recursive grammars, and keeps each production very simple.
Note that parentheses do not cause construction of AST nodes themselves. While we could do it this way, the most important role of parentheses are to guide the parser and provide grouping.
Once the parser constructs the AST, parentheses are not needed.

The next simple production is for handling variable references and function calls:

```c#
// identifierexpr
//   ::= identifier
//   ::= identifier '(' expression* ')'
private ExprAST ParseIdentifierExpr()
{
  string idName = this.scanner.GetLastIdentifier();

  this.scanner.GetNextToken();  // eat identifier.

  if (this.scanner.CurrentToken != '(') // Simple variable ref.
  {
    return new VariableExprAST(idName);
  }

  // Call.
  this.scanner.GetNextToken();  // eat (
  List<ExprAST> args = new List<ExprAST>();

  if (this.scanner.CurrentToken != ')')
  {
    while (true)
    {
      ExprAST arg = this.ParseExpression();
      if (arg == null)
      {
        return null;
      }

      args.Add(arg);

      if (this.scanner.CurrentToken == ')')
      {
        break;
      }

      if (this.scanner.CurrentToken != ',')
      {
        Console.WriteLine("Expected ')' or ',' in argument list");
        return null;
      }
      this.scanner.GetNextToken();
    }
  }
  
  // Eat the ')'.
  this.scanner.GetNextToken();

  return new CallExprAST(idName, args);
}
```

This routine follows the same style as the other routines. (It expects to be called if the current token is a `Token.IDENTIFIER` token). It also has recursion and error handling. One interesting aspect of this is that it uses look-ahead to determine if the current identifier is a stand alone variable reference or if it is a function call expression. It handles this by checking to see if the token after the identifier is a `(` token, constructing either a `VariableExprAST` or `CallExprAST` node as appropriate.

Now that we have all of our simple expression-parsing logic in place, we can define a helper function to wrap it together into one entry point. We call this class of expressions "primary" expressions, for reasons that will become more clear later in the tutorial. In order to parse an arbitrary primary expression, we need to determine what sort of expression it is:

```c#
// primary
//   ::= identifierexpr
//   ::= numberexpr
//   ::= parenexpr
private ExprAST ParsePrimary()
{
  switch (this.scanner.CurrentToken)
  {
    case (int) Token.IDENTIFIER:
      return this.ParseIdentifierExpr();
    case (int) Token.NUMBER:
      return this.ParseNumberExpr();
    case '(':
      return this.ParseParenExpr();
    default:
      Console.WriteLine("unknown token when expecting an expression");
      return null;
  }
}
```

Now that you see the definition of this function, it is more obvious why we can assume the state of CurTok in the various functions. This uses look-ahead to determine which sort of expression is being inspected, and then parses it with a function call.

Now that basic expressions are handled, we need to handle binary expressions. They are a bit more complex.

## 2.5. Binary Expression Parsing

Binary expressions are significantly harder to parse because they are often ambiguous.
For example, when given the string `x + y * z`, the parser can choose to parse it as either `(x + y) * z` or `x + (y * z)`.
With common definitions from mathematics, we expect the later parse, because `*` (multiplication) has higher precedence than `+` (addition).

There are many ways to handle this, but an elegant and efficient way is to use Operator-Precedence Parsing.
This parsing technique uses the precedence of binary operators to guide recursion. To start with, we need a table of precedences:

```c#
private readonly Dictionary<char, int> binopPrecedence;

public int GetTokPrecedence()
{
  // Make sure it's a declared binop.
  int tokPrec;
  if (this.binopPrecedence.TryGetValue((char)this.CurrentToken, out tokPrec))
  {
      return tokPrec;
  }

  return -1;
}

public static void Main()
{
  // Install standard binary operators.
  // 1 is lowest precedence.
  var binopPrecedence = new Dictionary<char, int>
  {
    ['<'] = 10,
    ['+'] = 20,
    ['-'] = 20,
    ['*'] = 40
  };
  ...
}
```

For the basic form of Kaleidoscope, we will only support 4 binary operators (this can obviously be extended by you, our brave and intrepid reader).
The `GetTokPrecedence` function returns the precedence for the current token, or `-1` if the token is not a binary operator.
Having a map makes it easy to add new operators and makes it clear that the algorithm doesn't depend on the specific operators involved, but it would be easy enough to eliminate the map and do the comparisons in the GetTokPrecedence function.
(Or just use a fixed-size array).

With the helper above defined, we can now start parsing binary expressions.
The basic idea of operator precedence parsing is to break down an expression with potentially ambiguous binary operators into pieces.
Consider, for example, the expression `a + b + (c + d) * e * f + g`.
Operator precedence parsing considers this as a stream of primary expressions separated by binary operators.
As such, it will first parse the leading primary expression `a`, then it will see the pairs `[+, b]` `[+, (c + d)]` `[*, e]` `[*, f]` and `[+, g]`.
Note that because parentheses are primary expressions, the binary expression parser doesn't need to worry about nested subexpressions like `(c + d)` at all.

To start, an expression is a primary expression potentially followed by a sequence of `[binop, primaryexpr]` pairs:

```c#
// expression
//   ::= primary binoprhs
//
private ExprAST ParseExpression()
{
  ExprAST lhs = this.ParsePrimary();
  if (lhs == null)
  {
      return null;
  }

  return this.ParseBinOpRHS(0, lhs);
}
```

`ParseBinOpRHS` is the function that parses the sequence of pairs for us.
It takes a precedence and a pointer to an expression for the part that has been parsed so far.
Note that `x` is a perfectly valid expression: As such, `binoprhs` is allowed to be empty, in which case it returns the expression that is passed into it. In our example above, the code passes the expression for `a` into `ParseBinOpRHS` and the current token is `+`.

The precedence value passed into `ParseBinOpRHS` indicates the minimal operator precedence that the function is allowed to eat.
For example, if the current pair stream is `[+, x]` and `ParseBinOpRHS` is passed in a precedence of 40, it will not consume any tokens (because the precedence of `+` is only 20).
With this in mind, `ParseBinOpRHS` starts with:

```c#
// binoprhs
//   ::= ('+' primary)*
private ExprAST ParseBinOpRHS(int exprPrec, ExprAST lhs)
{
  // If this is a binop, find its precedence.
  while (true)
  {
    int tokPrec = this.scanner.GetTokPrecedence();

    // If this is a binop that binds at least as tightly as the current binop,
    // consume it, otherwise we are done.
    if (tokPrec < exprPrec)
    {
      return lhs;
    }
```

This code gets the precedence of the current token and checks to see if if is too low.
Because we defined invalid tokens to have a precedence of `-1`, this check implicitly knows that the pair-stream ends when the token stream runs out of binary operators.
If this check succeeds, we know that the token is a binary operator and that it will be included in this expression:

```c#
// Okay, we know this is a binop.
int binOp = this.scanner.CurrentToken;
this.scanner.GetNextToken();  // eat binop

// Parse the primary expression after the binary operator.
ExprAST rhs = this.ParsePrimary();
if (rhs == null)
{
  return null;
}
```

As such, this code eats (and remembers) the binary operator and then parses the primary expression that follows.
This builds up the whole pair, the first of which is `[+, b]` for the running example.

Now that we parsed the left-hand side of an expression and one pair of the RHS sequence, we have to decide which way the expression associates.
In particular, we could have "`(a + b)` binop unparsed" or "`a + (b` binop unparsed)".
To determine this, we look ahead at "binop" to determine its precedence and compare it to BinOp's precedence (which is `+` in this case):

```c#
      ... if body omitted ...
    }

    // Merge LHS/RHS.
    lhs = new BinaryExprAST((char)binOp, lhs, rhs);
  }
}
```

In our example above, this will turn `a + b +` into `(a + b)` and execute the next iteration of the loop, with `+` as the current token.
The code above will eat, remember, and parse `(c + d)` as the primary expression, which makes the current pair equal to `[+, (c + d)]`. It will then evaluate the `if` conditional above with `*` as the binop to the right of the primary. In this case, the precedence of `*` is higher than the precedence of `+` so the if condition will be entered.

The critical question left here is "how can the if condition parse the right hand side in full"?
In particular, to build the AST correctly for our example, it needs to get all of `(c + d) * e * f` as the RHS expression variable.
The code to do this is surprisingly simple (code from the above two blocks duplicated for context):

```c#
    // If BinOp binds less tightly with RHS than the operator after RHS, let
    // the pending operator take RHS as its LHS.
    int nextPrec = this.scanner.GetTokPrecedence();
    if (tokPrec < nextPrec)
    {
      rhs = this.ParseBinOpRHS(tokPrec + 1, rhs);
      if (rhs == null)
      {
        return null;
      }
    }

    // Merge LHS/RHS.
    lhs = new BinaryExprAST((char)binOp, lhs, rhs);
  }
}
```

At this point, we know that the binary operator to the RHS of our primary has higher precedence than the binop we are currently parsing. As such, we know that any sequence of pairs whose operators are all higher precedence than `+` should be parsed together and returned as 'RHS'.
To do this, we recursively invoke the `ParseBinOpRHS` function specifying `TokPrec + 1` as the minimum precedence required for it to continue.
In our example above, this will cause it to return the AST node for `(c + d) * e * f` as RHS, which is then set as the RHS of the `+` expression.

Finally, on the next iteration of the while loop, the `+g` piece is parsed and added to the AST.
With this little bit of code, we correctly handle fully general binary expression parsing in a very elegant way.
This was a whirlwind tour of this code, and it is somewhat subtle.
I recommend running through it with a few tough examples to see how it works.

This wraps up handling of expressions.
At this point, we can point the parser at an arbitrary token stream and build an expression from it, stopping at the first token that is not part of the expression. Next up we need to handle function definitions, etc.

## 2.6. Parsing the Rest

The next thing missing is handling of function prototypes.
In Kaleidoscope, these are used both for `extern` function declarations as well as function body definitions. The code to do this is straight-forward and not very interesting (once you've survived expressions):

```c#

// prototype
//   ::= id '(' id* ')'
private PrototypeAST ParsePrototype()
{
  if (this.scanner.CurrentToken != (int)Token.IDENTIFIER)
  {
    Console.WriteLine("Expected function name in prototype");
    return null;
  }

  string fnName = this.scanner.GetLastIdentifier();

  this.scanner.GetNextToken();

  if (this.scanner.CurrentToken != '(')
  {
    Console.WriteLine("Expected '(' in prototype");
    return null;
  }

  List<string> argNames = new List<string>();
  while (this.scanner.GetNextToken() == (int)Token.IDENTIFIER)
  {
    argNames.Add(this.scanner.GetLastIdentifier());
  }

  if (this.scanner.CurrentToken != ')')
  {
    Console.WriteLine("Expected ')' in prototype");
    return null;
  }

  this.scanner.GetNextToken(); // eat ')'.

  return new PrototypeAST(fnName, argNames);
}
```

Given this, a function definition is very simple, just a prototype plus an expression to implement the body:

```c#
// definition ::= 'def' prototype expression
private FunctionAST ParseDefinition()
{
  this.scanner.GetNextToken(); // eat def.
  PrototypeAST proto = this.ParsePrototype();

  if (proto == null)
  {
    return null;
  }

  ExprAST body = this.ParseExpression();
  if (body == null)
  {
    return null;
  }

  return new FunctionAST(proto, body);
}
```

In addition, we support `extern` to declare functions like `sin` and `cos` as well as to support forward declaration of user functions.
These `extern`s are just prototypes with no body:

```c#
/// external ::= 'extern' prototype
private PrototypeAST ParseExtern()
{
  this.scanner.GetNextToken();  // eat extern.
  return this.ParsePrototype();
}
```

Finally, we'll also let the user type in arbitrary top-level expressions and evaluate them on the fly.
We will handle this by defining anonymous nullary (zero argument) functions for them:

```c#
/// toplevelexpr ::= expression
private FunctionAST ParseTopLevelExpr()
{
  ExprAST e = this.ParseExpression();
  if (e == null)
  {
    return null;
  }

  // Make an anonymous proto.
  PrototypeAST proto = new PrototypeAST(string.Empty, new List<string>());
  return new FunctionAST(proto, e);
}
```

Now that we have all the pieces, let's build a little driver that will let us actually execute this code we've built!

## 2.7. The Driver

The driver for this simply invokes all of the parsing pieces with a top-level dispatch loop.
There isn't much interesting here, so I'll just include the top-level loop. See [below](#29-full-code-listing) for full code in the "Top-Level Parsing" section.

```c#
private static void MainLoop(ILexer lexer, IParser parser)
{
  // top ::= definition | external | expression | ';'
  while (true)
  {
    Console.Write("ready> ");
    switch (lexer.CurrentToken)
    {
    case (int)Token.EOF:
      return;
    case ';':
      lexer.GetNextToken();
      break;
    case (int) Token.DEF:
      parser.HandleDefinition();
      break;
    case (int) Token.EXTERN:
      parser.HandleExtern();
      break;
    default:
      parser.HandleTopLevelExpression();
      break;
    }
  }
}
```

The most interesting part of this is that we ignore top-level semicolons.
Why is this, you ask?
The basic reason is that if you type `4 + 5` at the command line, the parser doesn't know whether that is the end of what you will type or not.
For example, on the next line you could type `def foo...` in which case `4 + 5` is the end of a top-level expression.
Alternatively you could type `* 6`, which would continue the expression.
Having top-level semicolons allows you to type `4 + 5;`, and the parser will know you are done.

## 2.8. Conclusions

With just under 400 lines of commented code (240 lines of non-comment, non-blank code), we fully defined our minimal language, including a lexer, parser, and AST builder. With this done, the executable will validate Kaleidoscope code and tell us if it is grammatically invalid. For example, here is a sample interaction:

```shell
$ ./a.out
ready> def foo(x y) x+foo(y, 4.0);
Parsed a function definition.
ready> def foo(x y) x+y y;
Parsed a function definition.
Parsed a top-level expr
ready> def foo(x y) x+y );
Parsed a function definition.
Error: unknown token when expecting an expression
ready> extern sin(a);
ready> Parsed an extern
ready> ^D
$
```

There is a lot of room for extension here.
You can define new AST nodes, extend the language in many ways, etc. In the next installment, we will describe how to generate LLVM Intermediate Representation (IR) from the AST.

## 2.9. Full Code Listing

[Here](https://github.com/Microsoft/LLVMSharp/blob/master/KaleidoscopeTutorial/Chapter3/)
is the complete code listing for this and the previous chapter.
Note that it is fully self-contained: you don't need LLVM or any external libraries at all for this. (Besides the C\# standard libraries, of course.)

[Next: Implementing Code Generation to LLVM IR](../CSharpLangImpl03)

