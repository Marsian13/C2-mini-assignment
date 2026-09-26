# CS3423 Mini Assignment 2 - Lex and Yacc

Team members:
Praneeth KODAVATI - CS24BTECH11034
Vansh Gupta - CS24BTECH11028

This covers all 3 questions. Each question has its own folder with
its own README going into more detail.

## Qn1 - "rule cannot be matched" warning
See `Qn1/README.md` and `Qn1/unreachable.l`.
Run with: `flex unreachable.l` and you'll see the warning printed.

## Qn2 - Shift/Reduce and Reduce/Reduce conflicts
See `Qn2/README.md`.
- `Qn2/sr/dangling_else.y` - shift/reduce conflict (dangling else)
- `Qn2/rr/reduce_reduce.y` - reduce/reduce conflict (ambiguous rules)
Run with: `bison -y -d <file>.y` and you'll see the conflict warning.

## Qn3 - Tcl subset to C++ transpiler
See `Qn3/README.md` for the full details, how types are figured out,
and the assumptions made.

```
cd Qn3/build
make
./tclc < ../test/input/t1.txt
```