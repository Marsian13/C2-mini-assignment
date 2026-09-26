# Qn1 - "warning, rule cannot be matched"

## When does this warning show up?

Lex (and flex) picks rules top to bottom. When two rules can match the
same input and give the same match length, flex always goes with
whichever rule is written first in the file. If a rule that comes
later can never win that competition because an earlier, more general
rule always grabs the same text first, that later rule is basically
dead code and will never run. Flex notices this while compiling the
`.l` file and prints:

```
warning, rule cannot be matched
```

This usually happens when:
- A broad pattern (like `[a-z]+` for any identifier) is placed above a
  narrower pattern (like the keyword `"if"`), so the broad rule always
  wins.
- Two rules are literally identical or one is a strict subset of
  another placed earlier.

## Example (see unreachable.l)

In `unreachable.l`, the rule for identifiers `[a-z]+` is written
before the rule for the keyword `"if"`. Since `"if"` is made up only
of lowercase letters, the identifier rule always matches it first, so
the `"if"` rule can never fire. Compiling it with flex gives:

```
$ flex unreachable.l
unreachable.l:8: warning, rule cannot be matched
```

## Fix

Move the keyword rule above the general identifier rule (or use a
lookup table / switch inside the identifier action to detect
keywords). That way the more specific pattern gets first chance to
match.
