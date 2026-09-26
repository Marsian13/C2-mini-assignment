/*
 * Qn3: Parser + code generator for the Tcl subset -> C++ transpiler.
 *
 * How it works:
 *  - Every expr carries two things: the C++ code text for it, and its
 *    inferred type (0 = int, 1 = float).
 *  - A tiny symbol table remembers each variable's type the first
 *    time it is "set", so later uses of that variable know their
 *    type, and so we only print the type keyword ("int"/"float") the
 *    first time a variable is declared.
 *  - Type rule (as asked in the assignment): if an expression mixes
 *    int and float, the result is float. So expr type = float if
 *    either side is float, else int.
 *  - All statements are generated as plain strings and concatenated;
 *    a small pretty-printer at the end (see main()) re-indents the
 *    final program based on braces, so the output stays readable.
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(const char *s);
extern int line_num;

/* ---------- tiny symbol table ---------- */
#define MAX_SYMS 256
typedef struct { char name[128]; int type; /*0=int,1=float*/ } Sym;
Sym symtab[MAX_SYMS];
int nsyms = 0;

int sym_lookup(const char *name) {
    for (int i = 0; i < nsyms; i++)
        if (strcmp(symtab[i].name, name) == 0) return i;
    return -1;
}

/* declare returns 1 if this is a brand new variable, 0 if already known */
int sym_declare(const char *name, int type) {
    int idx = sym_lookup(name);
    if (idx >= 0) { return 0; }
    strncpy(symtab[nsyms].name, name, sizeof(symtab[nsyms].name) - 1);
    symtab[nsyms].type = type;
    nsyms++;
    return 1;
}

int sym_type(const char *name) {
    int idx = sym_lookup(name);
    if (idx < 0) return 0; /* default to int if never declared */
    return symtab[idx].type;
}

const char *type_name(int t) { return t ? "float" : "int"; }

/* ---------- small string helpers (avoid manual malloc bookkeeping) --- */
char *strcat_new(const char *a, const char *b) {
    char *r = (char *)malloc(strlen(a) + strlen(b) + 1);
    strcpy(r, a); strcat(r, b);
    return r;
}
char *strcat3(const char *a, const char *b, const char *c) {
    char *r = (char *)malloc(strlen(a) + strlen(b) + strlen(c) + 1);
    strcpy(r, a); strcat(r, b); strcat(r, c);
    return r;
}

char *program_code = NULL; /* final accumulated program text */

void append_code(const char *s) {
    if (!program_code) { program_code = strdup(s); return; }
    program_code = strcat_new(program_code, s);
}
%}

%union {
    char *str;
    struct { char *code; int type; } expr;
}

%token IF ELSE WHILE PUTS SET
%token <str> ID VARID INTNUM FLOATNUM STRING
%token EQ AND OR

%type <expr> expr
%type <str> stmt_list stmt set_stmt puts_stmt if_stmt while_stmt block

%left OR
%left AND
%left EQ
%left '<' '>'
%left '+' '-'
%left '*' '/'

%%

program:
      stmt_list { append_code($1); }
    ;

stmt_list:
      /* empty */          { $$ = strdup(""); }
    | stmt_list stmt        { $$ = strcat_new($1, $2); }
    ;

stmt:
      set_stmt   { $$ = $1; }
    | puts_stmt  { $$ = $1; }
    | if_stmt    { $$ = $1; }
    | while_stmt { $$ = $1; }
    ;

set_stmt:
      SET ID expr ';' {
          int is_new = sym_declare($2, $3.type);
          char line[1024];
          if (is_new)
              snprintf(line, sizeof(line), "%s %s = %s;\n", type_name($3.type), $2, $3.code);
          else
              snprintf(line, sizeof(line), "%s = %s;\n", $2, $3.code);
          $$ = strdup(line);
      }
    ;

puts_stmt:
      PUTS STRING ';' {
          /* STRING includes the surrounding quotes, e.g. "$z" or "hello" */
          char inner[1024];
          size_t len = strlen($2);
          strncpy(inner, $2 + 1, len - 2); /* strip the quotes */
          inner[len - 2] = '\0';

          char line[1024];
          if (inner[0] == '$') {
              /* single variable interpolation: "$z" -> cout<<z<<"\n"; */
              snprintf(line, sizeof(line), "cout<<%s<<\"\\n\";\n", inner + 1);
          } else {
              /* plain literal string */
              snprintf(line, sizeof(line), "cout<<\"%s\"<<\"\\n\";\n", inner);
          }
          $$ = strdup(line);
      }
    ;

block:
      '{' stmt_list '}' { $$ = $2; }
    ;

if_stmt:
      IF '(' expr ')' block {
          char line[2048];
          snprintf(line, sizeof(line), "if(%s){\n%s}\n", $3.code, $5);
          $$ = strdup(line);
      }
    | IF '(' expr ')' block ELSE block {
          char line[4096];
          snprintf(line, sizeof(line), "if(%s){\n%s} else {\n%s}\n", $3.code, $5, $7);
          $$ = strdup(line);
      }
    ;

while_stmt:
      WHILE '(' expr ')' block {
          char line[2048];
          snprintf(line, sizeof(line), "while(%s){\n%s}\n", $3.code, $5);
          $$ = strdup(line);
      }
    ;

expr:
      expr '+' expr { $$.code = strcat3($1.code, "+", $3.code); $$.type = ($1.type || $3.type); }
    | expr '-' expr { $$.code = strcat3($1.code, "-", $3.code); $$.type = ($1.type || $3.type); }
    | expr '*' expr { $$.code = strcat3($1.code, "*", $3.code); $$.type = ($1.type || $3.type); }
    | expr '/' expr { $$.code = strcat3($1.code, "/", $3.code); $$.type = ($1.type || $3.type); }
    | expr '<' expr { $$.code = strcat3($1.code, "<", $3.code); $$.type = 0; }
    | expr '>' expr { $$.code = strcat3($1.code, ">", $3.code); $$.type = 0; }
    | expr EQ  expr { $$.code = strcat3($1.code, "==", $3.code); $$.type = 0; }
    | expr AND expr { $$.code = strcat3($1.code, "&&", $3.code); $$.type = 0; }
    | expr OR  expr { $$.code = strcat3($1.code, "||", $3.code); $$.type = 0; }
    | '(' expr ')'  { $$.code = strcat3("(", $2.code, ")"); $$.type = $2.type; }
    | VARID          { $$.code = strdup($1); $$.type = sym_type($1); }
    | INTNUM         { $$.code = strdup($1); $$.type = 0; }
    | FLOATNUM       { $$.code = strdup($1); $$.type = 1; }
    ;

%%

int yyerror(const char *s) {
    fprintf(stderr, "Parse error on line %d: %s\n", line_num, s);
    return 0;
}

/* Very small pretty-printer: re-indents program_code based on { } nesting
 * so the transpiled C++ is readable (assignment requirement 1c). */
void print_indented(FILE *out, const char *code) {
    int depth = 1; /* everything starts inside main() */
    const char *p = code;
    int at_line_start = 1;
    while (*p) {
        if (*p == '}') depth--;
        if (at_line_start) {
            for (int i = 0; i < depth; i++) fputs("    ", out);
            at_line_start = 0;
        }
        fputc(*p, out);
        if (*p == '{') depth++;
        if (*p == '\n') at_line_start = 1;
        p++;
    }
}

int main(void) {
    yyparse();

    FILE *out = fopen("output.cpp", "w");
    if (!out) { perror("output.cpp"); return 1; }

    fprintf(out, "#include <iostream>\nusing namespace std;\n\nint main(){\n");
    print_indented(out, program_code ? program_code : "");
    fprintf(out, "    return 0;\n}\n");

    fclose(out);
    printf("Wrote output.cpp\n");
    return 0;
}
