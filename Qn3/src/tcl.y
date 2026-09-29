%{
#include <bits/stdc++.h>


int yylex();
void yyerror(const char *s);

struct Expr{
    string code;
    int type;
};

map<string,int> mp;

string merge_expr(string a,string op,string b){
    return a+" "+op+" "+b;
}
%}

%union{
    char *str;
    Expr *expr;
}

%token IF ELSE WHILE PUTS SET
%token EQ AND OR

%token <str> VAR_REF ID FLOATNUM INTNUM STRING

%type <expr> expression

%left OR
%left AND
%left EQ
%left '<' '>'
%left '+' '-'
%left '*' '/'

%%

program:
    statements
    ;

statements:
      | statements statement
    ;

statement:
    assignment
    ;

assignment:
    SET ID expression ';'
    {
        mp[$2] = $3->type;

        if($3->type == 0)
            cout<<"int "<<$2<<" = "<<$3->code<<";"<<endl;
        else
            cout<<"float "<<$2<<" = "<<$3->code<<";"<<endl;
    }
    ;

expression:
    VAR_REF
    {
        $$ = new Expr;
        $$->code = $1;
        $$->type = mp[$1];
    }

    | INTNUM
    {
        $$ = new Expr;
        $$->code = $1;
        $$->type = 0;
    }

    | FLOATNUM
    {
        $$ = new Expr;
        $$->code = $1;
        $$->type = 1;
    }

    | expression '+' expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,"+",$3->code);
        $$->type = $1->type || $3->type;
    }

    | expression '-' expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,"-",$3->code);
        $$->type = $1->type || $3->type;
    }

    | expression '*' expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,"*",$3->code);
        $$->type = $1->type || $3->type;
    }

    | expression '/' expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,"/",$3->code);
        $$->type = $1->type || $3->type;
    }

    | expression '<' expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,"<",$3->code);
        $$->type = 0;
    }

    | expression '>' expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,">",$3->code);
        $$->type = 0;
    }

    | expression EQ expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,"==",$3->code);
        $$->type = 0;
    }

    | expression AND expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,"&&",$3->code);
        $$->type = 0;
    }

    | expression OR expression
    {
        $$ = new Expr;
        $$->code = merge_expr($1->code,"||",$3->code);
        $$->type = 0;
    }

    | '(' expression ')'
    {
        $$ = new Expr;
        $$->code = "("+$2->code+")";
        $$->type = $2->type;
    }
    ;

%%

void yyerror(const char *s){
    cerr<<s<<endl;
}

int main(){
    cout<<"#include <iostream>"<<endl;
    cout<<"using namespace std;"<<endl<<endl;

    yyparse();

    return 0;
}

