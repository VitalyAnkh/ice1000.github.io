---
layout: page
permalink: /llvm-cs/en/CSharpLangImpl04/
title: "Kaleidoscope: Implementing a Language with LLVM in CSharp"
---

# 4. Kaleidoscope: Adding JIT and Optimizer Support

## 4.1. Chapter 4 Introduction

Welcome to Chapter 4 of the "[Implementing a language with LLVM](../)" tutorial.
Chapters 1-3 described the implementation of a simple language and added support for generating LLVM IR. This chapter describes two new techniques: adding optimizer support to your language, and adding JIT compiler support.
These additions will demonstrate how to get nice, efficient code for the Kaleidoscope language.

## 4.2. Trivial Constant Folding

Our demonstration for Chapter 3 is elegant and easy to extend.
Unfortunately, it does not produce wonderful code.
The `LLVMBuilderRef`, however, does give us obvious optimizations when compiling simple code:

```
ready> def test(x) 1+2+x;
Read function definition:
define double @test(double %x) {
entry:
  %addtmp = fadd double 3.000000e+00, %x
  ret double %addtmp
}
```

This code is not a literal transcription of the AST built by parsing the input. That would be:

```
ready> def test(x) 1+2+x;
Read function definition:
define double @test(double %x) {
entry:
  %addtmp = fadd double 2.000000e+00, 1.000000e+00
  %addtmp1 = fadd double %addtmp, %x
  ret double %addtmp1
}
```

Constant folding, as seen above, in particular, is a very common and very important optimization: so much so that many language implementors implement constant folding support in their AST representation.

With LLVM, you don't need this support in the AST.
Since all calls to build LLVM IR go through the LLVM IR builder, the builder itself checked to see if there was a constant folding opportunity when you call it. If so, it just does the constant fold and return the constant instead of creating an instruction.

Well, that was easy :).
In practice, we recommend always using `LLVMBuilderRef` when generating code like this.
It has no "syntactic overhead" for its use (you don't have to uglify your compiler with constant checks everywhere) and it can dramatically reduce the amount of LLVM IR that is generated in some cases (particular for languages with a macro preprocessor or that use a lot of constants).

On the other hand, the `LLVMBuilderRef` is limited by the fact that it does all of its analysis inline with the code as it is built.
If you take a slightly more complex example:

```
ready> def test(x) (1+2+x)*(x+(1+2));
ready> Read function definition:
define double @test(double %x) {
entry:
  %addtmp = fadd double 3.000000e+00, %x
  %addtmp1 = fadd double %x, 3.000000e+00
  %multmp = fmul double %addtmp, %addtmp1
  ret double %multmp
}
```

In this case, the LHS and RHS of the multiplication are the same value. We'd really like to see this generate `tmp = x+3; result = tmp*tmp;` instead of computing `x+3` twice.

Unfortunately, no amount of local analysis will be able to detect and correct this. This requires two transformations: reassociation of expressions (to make the add's lexically identical) and Common Subexpression Elimination (CSE) to delete the redundant add instruction.
Fortunately, LLVM provides a broad range of optimizations that you can use, in the form of "passes".

## 4.3. LLVM Optimization Passes

LLVM provides many optimization passes, which do many different sorts of things and have different tradeoffs. Unlike other systems, LLVM doesn't hold to the mistaken notion that one set of optimizations is right for all languages and for all situations. LLVM allows a compiler implementor to make complete decisions about what optimizations to use, in which order, and in what situation.

As a concrete example, LLVM supports both "whole module" passes, which look across as large of body of code as they can (often a whole file, but if run at link time, this can be a substantial portion of the whole program). It also supports and includes "per-function" passes which just operate on a single function at a time, without looking at other functions. For more information on passes and how they are run, see the [How to Write a Pass document](http://releases.llvm.org/5.0.0/docs/WritingAnLLVMPass.html) and the [List of LLVM Passes](http://releases.llvm.org/5.0.0/docs/Passes.html).

For Kaleidoscope, we are currently generating functions on the fly, one at a time, as the user types them in.
We aren't shooting for the ultimate optimization experience in this setting, but we also want to catch the easy and quick stuff where possible.
As such, we will choose to run a few per-function optimizations as the user types the function in. If we wanted to make a "static Kaleidoscope compiler", we would use exactly the code we have now, except that we would defer running the optimizer until the entire file has been parsed.

In order to get per-function optimizations going, we need to set up a [FunctionPassManager](http://releases.llvm.org/5.0.0/docs/WritingAnLLVMPass.html#what-passmanager-doesr) to hold and organize the LLVM optimizations that we want to run.
Once we have that, we can add a set of optimizations to run.
We'll need a new FunctionPassManager for each module that we want to optimize, so we'll write a function to create and initialize both the module and pass manager for us:

```c#
// Make the module, which holds all the code.
LLVMModuleRef module = LLVM.ModuleCreateWithName("my cool jit");
LLVMBuilderRef builder = LLVM.CreateBuilder();

// Create a function pass manager for this engine
LLVMPassManagerRef passManager = LLVM.CreateFunctionPassManagerForModule(module);

// Do simple "peephole" optimizations and bit-twiddling optzns.
LLVM.AddInstructionCombiningPass(passManager);

// Reassociate expressions.
LLVM.AddReassociatePass(passManager);

// Eliminate Common SubExpressions.
LLVM.AddGVNPass(passManager);

// Simplify the control flow graph (deleting unreachable blocks, etc).
LLVM.AddCFGSimplificationPass(passManager);

LLVM.InitializeFunctionPassManager(passManager);
```

This code initializes the global module TheModule, and the function pass manager `passManager`, which is attached to `module`.
Once the pass manager is set up, we use a series of "add" calls to add a bunch of LLVM passes.

In this case, we choose to add four optimization passes.
The passes we choose here are a pretty standard set of "cleanup" optimizations that are useful for a wide variety of code.
I won't delve into what they do but, believe me, they are a good starting place :).

Once the `LLVMPassManagerRef` is set up, we need to make use of it.
We do this by running it after our newly created function is constructed (in `VisitFunctionAST`), but before it is returned to the client:

```c#
public void ExitHandleDefinition(FunctionAST data)
{
  this.visitor.Visit(data);
  var function = this.visitor.ResultStack.Pop();

  LLVM.RunFunctionPassManager(this.passManager, function);
}
```

As you can see, this is pretty straightforward. The `LLVMPassManagerRef` optimizes and updates the function in place, improving (hopefully) its body.
With this in place, we can try our test above again:

```
ready> def test(x) (1+2+x)*(x+(1+2));
ready> Read function definition:
define double @test(double %x) {
entry:
  %addtmp = fadd double %x, 3.000000e+00
  %multmp = fmul double %addtmp, %addtmp
  ret double %multmp
}
```

As expected, we now get our nicely optimized code, saving a floating point add instruction from every execution of this function.

LLVM provides a wide variety of optimizations that can be used in certain circumstances. Some [documentation about the various passes](http://releases.llvm.org/5.0.0/docs/Passes.html) is available, but it isn't very complete.
Another good source of ideas can come from looking at the passes that Clang runs to get started.
The "opt" tool allows you to experiment with passes from the command line, so you can see if they do anything.

Now that we have reasonable code coming out of our front-end, lets talk about executing it!

## 4.4. Adding a JIT Compiler

Code that is available in LLVM IR can have a wide variety of tools applied to it.
For example, you can run optimizations on it (as we did above), you can dump it out in textual or binary forms, you can compile the code to an assembly file (.s) for some target, or you can JIT compile it.
The nice thing about the LLVM IR representation is that it is the "common currency" between many different parts of the compiler.

In this section, we'll add JIT compiler support to our interpreter.
The basic idea that we want for Kaleidoscope is to have the user enter function bodies as they do now, but immediately evaluate the top-level expressions they type in.
For example, if they type in `1 + 2;`, we should evaluate and print out `3`.
If they define a function, they should be able to call it from the command line.

In order to do this, we first prepare the environment to create code for the current native target and declare and initialize the JIT.
This is done by calling some `InitializeX86Target` functions and adding a variable `engine`, initializing it in main, and making it a global variable before execution:

```c#
LLVM.LinkInMCJIT();
LLVM.InitializeX86TargetInfo();
LLVM.InitializeX86Target();
LLVM.InitializeX86TargetMC();

LLVM.InitializeX86AsmParser();
LLVM.InitializeX86AsmPrinter();

var binopPrecedence = new Dictionary<char, int>
{
  ['<'] = 10,
  ['+'] = 20,
  ['-'] = 20,
  ['*'] = 40
};

LLVMMCJITCompilerOptions options = new LLVMMCJITCompilerOptions { NoFramePointerElim = 1 };
LLVM.InitializeMCJITCompilerOptions(options);
if (LLVM.CreateExecutionEngineForModule(out var engine, module, out var errorMessage).Value == 1)
{
  Console.WriteLine(errorMessage);
  return;
}

var codeGenlistener = new CodeGenParserListener(engine, passManager, new CodeGenVisitor(module, builder));

var scanner = new Lexer(Console.In, binopPrecedence);
var parser = new Parser(scanner, codeGenlistener);

// Prime the first token.
Console.Write("ready> ");
scanner.GetNextToken();

// Run the main "interpreter loop" now.
MainLoop(scanner, parser);

LLVM.DisposeBuilder(builder);
LLVM.DisposeExecutionEngine(engine);
```

<!-- We also need to setup the data layout for the JIT: -->

<!-- ```c# -->
<!-- // Set up the optimizer pipeline.  Start with registering info about how the -->
<!-- // target lays out data structures. -->
<!-- LLVM.DisposeTargetData(LLVM.GetExecutionEngineTargetData(engine)); -->
<!-- ``` -->

We use a `LLVMExecutionEngineRef` (the type of `engine`) to do execution.

We can take this simple API and change our code that parses top-level expressions to look like this:

```c#
public class Program
{
  public delegate double D();
}

public void ExitHandleTopLevelExpression(FunctionAST data)
{
  this.visitor.Visit(data);
  var anonymousFunction = this.visitor.ResultStack.Pop();
  LLVM.DumpValue(anonymousFunction); // Dump the function for exposition purposes.
  var dFunc = (Program.D) Marshal.GetDelegateForFunctionPointer(LLVM.GetPointerToGlobal(this.ee, anonymousFunction), typeof(Program.D));
  LLVM.RunFunctionPassManager(this.passManager, anonymousFunction);

  LLVM.DumpValue(anonymousFunction); // Dump the function for exposition purposes.
  Console.WriteLine("Evaluated to " + dFunc());
}
```


If parsing and codegen succeeed, the next step is to add the module containing the top-level expression to the JIT.
We do this by calling `visitor.Visit(data)`, which triggers code generation for the function we need, and `visitor.ResultStack.Pop()` returns the function (`ResultStack` is just an alias of `valueStack`) as a `LLVMValueRef`.
`GetPointerToGlobal` gets the pointer to the function holds by the `LLVMValueRef`.

In this way we get the JITed function easily and safely, much better than the approach introduced in the official C\+\+ document. :)

At last we call the returned `dFunc`, and we see the result.

With just these changes, lets see how Kaleidoscope works now!

```
ready> 4+5;
Read top-level expression:
define double @0() {
entry:
  ret double 9.000000e+00
}

Evaluated to 9.000000
```

Well this looks like it is basically working.
The dump of the function shows the "no argument function that always returns double" that we synthesize for each top-level expression that is typed in.
This demonstrates very basic functionality, but can we do more?

```
ready> def testfunc(x y) x + y*2;
Read function definition:
define double @testfunc(double %x, double %y) {
entry:
  %multmp = fmul double %y, 2.000000e+00
  %addtmp = fadd double %multmp, %x
  ret double %addtmp
}

ready> testfunc(4, 10);
Read top-level expression:
define double @1() {
entry:
  %calltmp = call double @testfunc(double 4.000000e+00, double 1.000000e+01)
  ret double %calltmp
}

Evaluated to 24.000000
```

<!-- Function definitions and calls also work, but something went very wrong on that last line. -->
<!-- The call looks valid, so what happened? -->
<!-- As you may have guessed from the the API a Module is a unit of allocation for the JIT, and `testfunc` was part of the same module that contained anonymous expression. -->
<!-- When we removed that module from the JIT to free the memory for the anonymous expression, we deleted the definition of `testfunc` along with it. -->
<!-- Then, when we tried to call testfunc a second time, the JIT could no longer find it. -->

<!-- The easiest way to fix this is to put the anonymous expression in a separate module from the rest of the function definitions. -->
<!-- The JIT will happily resolve function calls across module boundaries, as long as each of the functions called has a prototype, and is added to the JIT before it is called. -->
<!-- By putting the anonymous expression in a different module we can delete it without affecting the rest of the functions. -->

<!-- In fact, we're going to go a step further and put every function in its own module. Doing so allows us to exploit a useful property of the KaleidoscopeJIT that will make our environment more REPL-like: Functions can be added to the JIT more than once (unlike a module where every function must have a unique definition). -->
<!-- When you look up a symbol in KaleidoscopeJIT it will always return the most recent definition: -->

<!-- ``` -->
<!-- ready> def foo(x) x + 1; -->
<!-- Read function definition: -->
<!-- define double @foo(double %x) { -->
<!-- entry: -->
<!--   %addtmp = fadd double %x, 1.000000e+00 -->
<!--   ret double %addtmp -->
<!-- } -->

<!-- ready> foo(2); -->
<!-- Evaluated to 3.000000 -->

<!-- ready> def foo(x) x + 2; -->
<!-- define double @foo(double %x) { -->
<!-- entry: -->
<!--   %addtmp = fadd double %x, 2.000000e+00 -->
<!--   ret double %addtmp -->
<!-- } -->

<!-- ready> foo(2); -->
<!-- Evaluated to 4.000000 -->
<!-- ``` -->

<!-- In the future we'll see how tweaking this symbol resolution rule can be used to enable all sorts of useful features, from security (restricting the set of symbols available to JIT'd code), to dynamic code generation based on symbol names, and even lazy compilation. -->

<!-- One immediate benefit of the symbol resolution rule is that we can now extend the language by writing arbitrary C\+\+ code to implement operations. -->
<!-- For example, if we add: -->

<!-- ```c++ -->
<!-- #ifdef LLVM_ON_WIN32 -->
<!-- #define DLLEXPORT __declspec(dllexport) -->
<!-- #else -->
<!-- #define DLLEXPORT -->
<!-- #endif -->

<!-- /// putchard - putchar that takes a double and returns 0. -->
<!-- extern "C" DLLEXPORT double putchard(double x) { -->
<!--   fputc((char) x, stderr); -->
<!--   return 0; -->
<!-- } -->
<!-- ``` -->

<!-- Note, that for Windows we need to actually export the functions because the dynamic symbol loader will use `GetProcAddress` to find the symbols. -->

<!-- Now we can produce simple output to the console by using things like: `extern putchard(x); putchard(120);`, which prints a lowercase `x` on the console (120 is the ASCII code for `x`). -->
<!-- Similar code could be used to implement file I/O, console input, and many other capabilities in Kaleidoscope. -->

__The `extern` and `addModule` related parts in the C\+\+ version are not available in the C\# version. Please mention.__

This completes the JIT and optimizer chapter of the Kaleidoscope tutorial.
At this point, we can compile a non-Turing-complete programming language, optimize and JIT compile it in a user-driven way.

<!-- Next up we'll look into extending the [language with control flow constructs](../CSharpLangImpl05/), tackling some interesting LLVM IR issues along the way. -->

## 4.5. Full Code Listing

[Here](https://github.com/Microsoft/LLVMSharp/blob/master/KaleidoscopeTutorial/Chapter4/KaleidoscopeLLVM/)
is the complete code listing for our running example, enhanced with the LLVM JIT and optimizer.
Notice: it uses C\#'s reflection to invoke the core `ExitHandleTopLevelExpression` function.
