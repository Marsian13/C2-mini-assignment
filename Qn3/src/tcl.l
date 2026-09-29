%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "tcl.tab.h"
%}

%%

[ \t\n]+                   ;

"if"                     { return IF; }
"else"                   { return ELSE; }
"while"                  { return WHILE; }
"puts"                   { return PUTS; }
"set"                    { return SET; }

"=="                     { return EQ; }
"&&"                     { return AND; }
"||"                     { return OR; }

"$"[a-zA-Z][a-zA-Z0-9_]* { yylval.str = strdup(yytext + 1); return VARID; }

[a-zA-Z][a-zA-Z0-9_]*   { yylval.str = strdup(yytext); return ID; }
[0-9]+\.[0-9]+           { yylval.str = strdup(yytext); return FLOATNUM; }

[0-9]+                   { yylval.str = strdup(yytext); return INTNUM; }
\"[^\"]*\"               { yylval.str = strdup(yytext); return STRING; }

"+"                      { return '+'; }
"-"                      { return '-'; }
"*"                      { return '*'; }
"/"                      { return '/'; }
"<"                      { return '<'; }
">"                      { return '>'; }
"="                      { return '='; }
"("                      { return '('; }
")"                      { return ')'; }
"{"                      { return '{'; }
"}"                      { return '}'; }
";"                      { return ';'; }

.                        ;

%%

int yywrap(void) { 
  return 1; 
}
