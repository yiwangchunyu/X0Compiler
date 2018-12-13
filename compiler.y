%token  ID NUM
%token  PLUS MINUS TIMES SLASH EQL NEQ LES LEQ GTR GEQ 
%token  LPAREN RPAREN LBRACKETS RBRACKETS LBRACE RBRACE 
%token  COMMA SEMICOLON PERIOD BECOMES 
%token  MAIN IF ELSE WHILE WRITE READ DO CALL INT CHAR 
/*
%left    '+' '-'
%left    '*' '/'
%left    '&'
%left    '|'
%left    '^'
%right   '@''~'
%left    '!'
*/

%{


#include <stdio.h>   
#include <math.h>
#include "string.h"
void yyerror(char*);
int yylex(void);
FILE *yout;
FILE *yyin;
%}

%%
program:
    MAIN LBRACE declaration_list statement_list RBRACE {printf("main over");}
    ;

declaration_list:
     declaration_list declaration_stat {printf("declaration_list declaration_stat\n");}
     |declaration_stat {printf("declaration_stat\n");}
     | {}
     ;

declaration_stat:
    type ID SEMICOLON {printf("type ID;\n");}
    |type ID LBRACKETS NUM RBRACKETS SEMICOLON {}
    ;

type:
    INT {printf("int\n");}
    |CHAR {}
    ;

var:
    ID {}
    | ID LBRACKETS expression RBRACKETS {printf("ID");}
    ;

statement_list:
    statement_list statement {}
    |
    ;

statement:
    if_stat {}
    |while_stat {}
    |read_stat {}
    |write_stat {}
    |compound_stat {}
    |expression_stat {}
    ;

if_stat:
    IF LPAREN expression RPAREN statement ELSE statement {}
    |IF LPAREN expression RPAREN statement {}
    ;

while_stat:
    WHILE LPAREN expression RPAREN statement {}
    ;

write_stat:
    WRITE expression SEMICOLON {}
    ;

read_stat:
    READ var SEMICOLON {}
    ;

compound_stat:
    LBRACE statement_list RBRACE {}
    ;

expression_stat: 
    expression SEMICOLON {}
    | SEMICOLON {}
    ;

expression:
    var BECOMES expression {}
    | simple_expr {}
    ;

simple_expr:
    additive_expr {}
    | additive_expr operator additive_expr {}
    ;

operator:
    GTR {}
    |LES {}
    |GEQ {}
    |LEQ {}
    |EQL {}
    |NEQ {}
    ;

additive_expr:
    term  {}
    |additive_expr additive_op term {}
    ;

additive_op:
    PLUS {}
    |MINUS {}
    ;

term:
    factor  {}
    |term term_op factor {}
    ;

term_op:
    TIMES {}
    |SLASH {}
    ;

factor:
    LPAREN expression RPAREN {}
    |var {}
    |NUM {}
    ;

%%

void yyerror(char* s)
{
    fprintf(stderr, "%s\n", s);
    //fclose(yout);
}

int main(int argc,char *argv[])
{
    int i;
    if (argc > 1) {
        for (i = 1; i < argc; i++)
        {
            if ((strcmp(argv[i], "-f")==0) && (argc > i+1))
            {
                yyin = fopen(argv[++i],"r");
                break;
            }
            if(argc>i){
                yyin = fopen(argv[i++],"r");
            }
        }
    }
    printf("pl0 compiler\n");
    yyparse();
    return 0;
}