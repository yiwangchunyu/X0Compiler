%token  <ident> ID 
%token  <number> NUM
%token  PLUS MINUS TIMES SLASH EQL NEQ LES LEQ GTR GEQ 
%token  LPAREN RPAREN LBRACKETS RBRACKETS LBRACE RBRACE 
%token  COMMA SEMICOLON PERIOD BECOMES 
%token  MAIN IF ELSE WHILE WRITE READ DO CALL INT CHAR 

%type <number> var
%type <number> get_code_addr

%left    ELSE
%left    PLUS MINUS
%left    TIMES SLASH


%{

#include <stdio.h>   
#include <stdlib.h>
#include <math.h>
#include "string.h"
#include "code.h"
#include "malloc.h"
void yyerror(char*);
int yylex(void);
FILE *yout;
FILE *yyin;
%}

%union{
char *ident;
int number;
}

%%
program:
    MAIN LBRACE     {
                        dx=3;
                        procReg.tx0=tx;
                        table[tx].adr=cx;
                        gen(jmp,0,1);
                    }
    declaration_list    {
                            code[table[procReg.tx0].adr].a=cx;
                            strcpy(table[procReg.tx0].name,"main");
                            table[procReg.tx0].kind=procedur;
                            table[procReg.tx0].type=none_t;
                            table[procReg.tx0].adr=cx;
                            table[procReg.tx0].size=dx;
                            procReg.cx0=cx;
                            gen(ini,0,dx);
                        }
    statement_list      {
                            gen(opr,0,0);
                        } 
    RBRACE {printf("main over");}
    ;

declaration_list:
     declaration_list declaration_stat {}
     |declaration_stat  {
                            procReg.dx0=dx;
                        }
     | {}
     ;

declaration_stat:
    type ID SEMICOLON   { 
                            array=0;
                            strcpy(id,$2);
                            enter(variable);
                        }
    |type ID LBRACKETS NUM RBRACKETS SEMICOLON  {
                                                    array=1;
                                                    array_size=(int*)malloc(sizeof(int));
                                                    *array_size = $4;
                                                    array_dim=1;
                                                    strcpy(id,$2);
                                                    enter(variable);
                                                }
    ;

type:
    INT {type=int_t;}
    |CHAR {type=char_t;}
    ;

var:
    ID  {
            int i = position ($1);
            if(i==0){
                error(0);
            }
            $$ = i;
        }
    | ID LBRACKETS expression RBRACKETS     {
                                                $$ = position ($1);
                                            }
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
    |IF LPAREN expression RPAREN get_code_addr  {
                                                    gen(jpc, 0, 0);
                                                }
    statement   {
                    code[$5].a = cx;
                }
    ;

while_stat:
    WHILE get_code_addr LPAREN expression RPAREN get_code_addr  {
                                                                    gen(jpc, 0 , 0);
                                                                }
    statement   {
                    gen(jmp, 0, $2);
                    code[$6].a = cx;
                }
    ;

write_stat:
    WRITE expression SEMICOLON  {
                                    gen(opr,0,14);
                                }
    |WRITE var SEMICOLON        {
                                    if(table[$2].type==char_t)
                                        gen(opr,0,17);
                                    else if(table[$2].type==int_t)
                                        gen(opr,0,14);
                                    else
                                        error(0);
                                }
    ;

read_stat:
    READ var SEMICOLON  {
                            gen(opr,0,16);
                            gen(sto,0,table[$2].adr);
                        }
    ;

compound_stat:
    LBRACE statement_list RBRACE {}
    ;

expression_stat: 
    expression SEMICOLON {}
    | SEMICOLON {}
    ;

expression:
    var BECOMES expression  {
                                gen(sto,0,table[$1].adr);
                                gen(lod,0,table[$1].adr);
                            }
    | simple_expr {}
    ;

simple_expr:
    additive_expr {}
    | additive_expr GTR additive_expr   {
                                            gen(opr,0,12);
                                        }
    | additive_expr LES additive_expr   {
                                            gen(opr,0,10);
                                        }
    | additive_expr GEQ additive_expr   {
                                            gen(opr,0,11);
                                        }
    | additive_expr LEQ additive_expr   {
                                            gen(opr,0,13);
                                        }
    | additive_expr EQL additive_expr   {
                                            gen(opr,0,8);
                                        }
    | additive_expr NEQ additive_expr   {
                                            gen(opr,0,9);
                                        }
    ;


additive_expr:
    term  {}
    |additive_expr PLUS term    {
                                    gen(opr,0,2);
                                }
    |additive_expr MINUS term   {
                                    gen(opr,0,3);
                                }
    ;

term:
    factor      {   

                }
    |term TIMES factor  {
                            gen(opr,0,4);
                        }
    |term SLASH factor  {
                            gen(opr,0,5);
                        }
    ;

factor:
    LPAREN expression RPAREN {}
    |var    {
                switch(table[$1].kind){
                    case constant:
                        gen(lit,0,table[$1].val);
                        break;
                    case variable:
                        if (table[$1].array)
                        {
                            gen(lod,0,table[$1].adr+0);
                        }else
                        {
                            gen(lod,0,table[$1].adr);
                        }
                        break;
                    case procedur:
                        error(21);
                        break;
                    }
            }
    |NUM    {
                int num;
                num=$1;
                if(num>AMAX){
                    error(31);
                    num=0;
                    }
                gen(lit,0,num);
            }
    ;
/*
get_table_addr:
               {
                $$ = tx;
               } 
          ;
*/
get_code_addr:
               {
                $$ = cx;
               }
          ;
%%


void yyerror(char *s){
    err++;
    printf("%s in line %d\n",s,line);
    fprintf(fa1,"%s in line %d\n",s,line);
}

int main(int argc,char *argv[])
{
    int i;
    listswitch=false;
    if (argc > 1) {
        for (i = 1; i < argc; i++)
        {
            if (strcmp(argv[i], "-c")==0)
            {
                listswitch=true;
            }
            else if ((strcmp(argv[i], "-f")==0) && (argc > i+1))
            {
                yyin = fopen(argv[++i],"r");
            }
            else if(argc>i){
                yyin = fopen(argv[i],"r");
            }
            else
            {

            }
        }
    }
    printf("pl0 compiler\n");
    if((fa1=fopen("fa1.txt","w"))==NULL){
        printf("Cann't open file!\n");
        exit(0);
        }
    if((fa=fopen("fa.txt","w"))==NULL){
        printf("Cann't open fa.txt file!\n");
        exit(0);
    }
    if((fa2=fopen("fa2.txt","w"))==NULL){
        printf("Cann't open fa2.txt file!\n");
        exit(0);
    }
    yyparse();
    fclose(fa);
    fclose(fa1);
    if(err==0)
    {
        listcode();
        interpret();
    }
    
    else
        printf("%d errors in PL/0 program\n",err);

    printTable(0);
    return 0;
}