%{
    #include <stdio.h>
%}

%%

[a-z]+      { printf("IDENTIFIER: %s\n", yytext); }
"if"        { printf("KEYWORD IF (this line can never run)\n"); }
[0-9]+      { printf("NUMBER: %s\n", yytext); }
.           ;

%%

int main() {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
