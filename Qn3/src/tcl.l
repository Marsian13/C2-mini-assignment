/*
 * Qn3: Lexer for the Tcl subset described in the assignment.
 * Tokenizes keywords, identifiers, $variables, numbers, strings and
 * operators, then hands them to the yacc parser (tcl.y).
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tcl.tab.h"

/* keep track of line numbers, useful for error messages */
int line_num = 1;
%}

%%

[ \t]+                  { /* skip whitespace, keeps generated code readable */ }
\n                       { line_num++; }
"//".*                   { /* skip single line comments if any */ }

"if"                     { return IF; }
"else"                   { return ELSE; }
"while"                  { return WHILE; }
"puts"                   { return PUTS; }
"set"                    { return SET; }

"=="                     { return EQ; }
"&&"                     { return AND; }
"||"                     { return OR; }

"$"[a-zA-Z_][a-zA-Z0-9_]* {
                            yylval.str = strdup(yytext + 1); /* drop the $ */
                            return VARID;
                          }

[a-zA-Z_][a-zA-Z0-9_]*   {
                            yylval.str = strdup(yytext);
                            return ID;
                          }

[0-9]+\.[0-9]+           {
                            yylval.str = strdup(yytext);
                            return FLOATNUM;
                          }

[0-9]+                   {
                            yylval.str = strdup(yytext);
                            return INTNUM;
                          }

\"[^\"]*\"                {
                            yylval.str = strdup(yytext);
                            return STRING;
                          }

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

.                        { fprintf(stderr, "Unexpected character '%s' on line %d\n", yytext, line_num); }

%%

int yywrap(void) { return 1; }
