# Qn3 - Tcl subset to C++ transpiler

## What this does

Reads a small Tcl-like program (only `set`, `puts`, `if`/`else`,
`while`, and basic math/comparison operators, as described in the
assignment) and writes out an equivalent `output.cpp` file.

## Files

- `src/tcl.l` - lexer, turns the input text into tokens
- `src/tcl.y` - parser + code generator, builds the C++ code and does
  type inference
- `build/Makefile` - builds everything into `build/tclc`

## How types are decided

- A variable is declared the first time it is `set`. If the number
  has a decimal point (like `2.02`) it is `float`, otherwise `int`.
- Any variable is remembered in a small symbol table (name + type)
  so later uses know if it's `int` or `float`.
- For an expression that mixes int and float (like `$x + $y` where x
  is int and y is float), the result type is `float`, as the
  assignment asks. This is just: if either side of an operator is
  float, the whole expression becomes float.
- Comparison and logic operators (`<`, `>`, `==`, `&&`, `||`) always
  give a boolean-ish result and don't affect the float/int rule.

## How to build and run

```
cd build
make
./tclc < ../test/input/t1.txt
```

This produces `output.cpp` in the `build` folder. `tclc` always reads
from stdin and writes `output.cpp`.

To also run the generated program:
```
g++ -o prog output.cpp
./prog
```

## Test cases

- `test/input/t1.txt` - the exact example from the assignment sheet.
  `test/output/output1.cpp` is what our tool generates for it, and it
  matches the expected output in the PDF. `test/printed/printed1.txt`
  is what that C++ program prints when run.
- `test/input/t2.txt` - a second test with `if/else` and plain
  (non-variable) strings in `puts`, to check that path too.
  `test/output/output2.cpp` and `test/printed/printed2.txt` are its
  generated code and its printed result.

## Assumptions / simplifications made

- `puts` only supports either a single variable in quotes (like
  `"$z"`) or a plain literal string (like `"big"`). It doesn't try to
  handle multiple variables mixed inside one string, since the
  assignment's own example only ever shows one variable per `puts`.
- Indentation in the generated C++ is added by a small pretty-printer
  at the end (based on counting `{` and `}`), rather than trying to
  track indent level while parsing. Keeps the parser simpler and the
  output still comes out readable.
- Undeclared variables used with `$` default to `int` instead of
  throwing a hard error, just to keep the tool from crashing on typos
  during testing.
