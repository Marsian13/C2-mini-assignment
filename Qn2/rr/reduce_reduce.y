%{
    #include <stdio.h>
%}

%token ID

%%

stmt:
      func_call
    | array_access
    ;

func_call:
      ID '(' ID ')'
    ;

array_access:
      ID '(' ID ')'
    ;

%%

int main() { 
  return 0; 
}

int yyerror(const char *s) { return 0; }

int yylex() { return 0; }
