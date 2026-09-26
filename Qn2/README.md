# Qn2 - Shift/Reduce and Reduce/Reduce conflicts

## Shift/Reduce conflict (sr/dangling_else.y)

This is the classic "dangling else" problem.

Grammar:
```
stmt : IF '(' expr ')' stmt
     | IF '(' expr ')' stmt ELSE stmt
     | ID
     ;
```

If you write `if (a) if (b) c; else d;`, once the parser has parsed
the inner `if (b) c` and looks ahead and sees `else`, it does not know
if that `else` belongs to the inner `if` or the outer `if`. It can
either:
- shift the `else` (attach it to the nearest if), or
- reduce the inner if-statement first (which would let the else
  attach to the outer if)

Both are grammatically valid, so bison reports it as a shift/reduce
conflict. Compiling gives:

```
$ bison -y -d dangling_else.y
dangling_else.y: warning: 1 shift/reduce conflict
```

Bison's default behaviour is to shift, which happens to match how
every C-like language actually resolves this (else binds to the
nearest unmatched if), so this particular conflict is usually left
alone rather than fixed.

## Reduce/Reduce conflict (rr/reduce_reduce.y)

Grammar:
```
func_call     : ID '(' ID ')' ;
array_access  : ID '(' ID ')' ;
```

Both rules are made of the exact same tokens: `ID '(' ID ')'`. So
once the parser has read all four tokens, it has to decide whether to
reduce them into a `func_call` or into an `array_access`, and the
grammar gives it no way to tell the two apart. Compiling gives:

```
$ bison -y -d reduce_reduce.y
reduce_reduce.y: warning: 1 reduce/reduce conflict
reduce_reduce.y: warning: rule useless in parser due to conflicts
```

Bison just picks whichever rule was declared first (`func_call`
here), and quietly ignores `array_access` completely, that rule
becomes unreachable, which is exactly the same kind of problem as
Qn1's "rule cannot be matched", just on the grammar side instead of
the lexer side.

### Fix
Reduce/reduce conflicts are more serious than shift/reduce ones
because the "wrong" choice is silent. The real fix is to make the two
rules distinguishable, for example using different token sequences or
different non-terminal names based on context (symbol table lookup),
rather than relying on the parser to guess.
