%{
    #include <stdio.h>
%}

%token IF ELSE ID

%%

stmt:
    IF '(' expr ')' stmt
    | IF '(' expr ')' stmt ELSE stmt
    | ID
    ;

expr:
    ID
    ;

%%

int main() { 
  return 0; 
}

int yyerror(const char *s) { 
  return 0; 
}

int yylex() { 
  return 0; 
}
