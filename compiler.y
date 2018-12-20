%token  <ident> ID 
%token  <number> NUM
%token  <type>  INT CHAR 
%token  PLUS MINUS TIMES SLASH EQL NEQ LES LEQ GTR GEQ MOD XOR ODD SPLUS SMINUS UMINUS
%token  LPAREN RPAREN LBRACKETS RBRACKETS LBRACE RBRACE 
%token  COMMA SEMICOLON PERIOD BECOMES COLON
%token  MAIN IF ELSE WHILE WRITE READ DO CALL SWITCH CASE DEFAULT BREAK FOR

%type <number> var
%type <number> get_code_addr
%type <number> else_stat
%type <number> array_size
%type <number> array_loc
%type <type> type

%right   ODD
%left    XOR
%left    PLUS MINUS
%left    TIMES SLASH MOD
%left    SPLUS SMINUS UMINUS
%nonassoc ELSE


%{

#include <stdio.h>   
#include <stdlib.h>
#include <math.h>
#include "string.h"
#include "code.h"
#include "malloc.h"
void yyerror(char*);
void syntax_error(char* s);
int yylex(void);
FILE *yout;
FILE *yyin;
struct list* array_ids;
%}

%union{
char *ident;
int number;
void* ptr;
char *type;
struct databus* db;
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
     declaration_list declaration_stat  {
                                            procReg.dx0=dx;
                                        }
     | {}
     ;

declaration_stat:
    type ID array_size SEMICOLON    {
                                        if(strcmp($1,"int")==0){
                                            type=int_t;
                                        } else if(strcmp($1,"char")==0){
                                            type=char_t;
                                        } else{
                                            type=none_t;
                                        }

                                        if(array==1){
                                            strcpy(id,$2);
                                            enter(variable);
                                        }else
                                        {
                                            strcpy(id,$2);
                                            enter(variable);
                                        }
                                        type=none_t;
                                    }
    ;

array_size:
    array_size LBRACKETS NUM RBRACKETS      {
                                                array=1;
                                                array_dim++;
                                                array_size=list_add(array_size,$3);
                                            }
    |   {   
            array=0;
            array_dim=0;
            array_size=NULL;
        }
    ;
type:
    INT {$$=$1;}
    |CHAR {$$=$1;}
    ;

var:
    ID  {
            int i = position ($1);
            if(i==0){
                error(0);
            }
            $$ = i;
            if(table[i].array){
                array_ids = list_add(array_ids,i);
            }
        }
    /*
    | ID LBRACKETS expression RBRACKETS     {
                                                $$ = position ($1);
                                            }
    */
    ;

statement_list:
    statement_list statement {}
    |statement {}
    ;

statement:
    if_stat {}
    |while_stat {}
    |read_stat {}
    |write_stat {}
    |compound_stat {}
    |expression_stat {}
    /*|switch_case_stat {}*/
    |for_stat {}
    |do_while_stat {}
    ;

for_stat:
    FOR LPAREN expression SEMICOLON get_code_addr simple_expr SEMICOLON get_code_addr   {
                                                                                            gen(jpc,0,0);
                                                                                            gen(jmp,0,0);
                                                                                        }
    expression  {
                    gen(jmp,0,$5);
                }
    RPAREN LBRACE get_code_addr statement_list RBRACE   {
                                                            gen(jmp,0,$8+2);
                                                            code[$8].a=cx;
                                                            code[$8+1].a=$14;
                                                        }
    ;

do_while_stat:
    DO LBRACE get_code_addr statement_list RBRACE WHILE LPAREN simple_expr RPAREN SEMICOLON get_code_addr   {
                                                                                                                gen(jpc,0,$11+2);
                                                                                                                gen(jmp,0,$3);
                                                                                                            }
    ;
/*switch_case_stat:
    SWITCH LPAREN expression RPAREN LBRACE case_list default_stat RBRACE {}
    ;

case_list:
    case_list CASE expression COLON statement_list {}
    ;

default_stat:
    DEFAULT COLON statement_list {}
    ;
*/
if_stat:
    IF LPAREN expression RPAREN get_code_addr   {
                                                    gen(jpc, 0, 0);
                                                } 
    statement else_stat   {
                    code[$5].a = $8;
                }
    ;

else_stat:
    ELSE get_code_addr  {
                            gen(jmp,0,0);
                        } 
    statement   {
                    $$=$2+1;
                    code[$2].a=cx;
                }
    |   {
            $$ = cx;
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
                                    gen(lod,0,table[$2].adr);
                                    if(table[$2].type==char_t)
                                        gen(opr,0,17);
                                    else if(table[$2].type==int_t)
                                        gen(opr,0,14);
                                    else
                                        error(0);
                                                
                                }   
    ;

array_loc:
    array_loc LBRACKETS expression RBRACKETS        {
                                                        int id=list_get_last(array_ids);
                                                        int dim_id=$1;
                                                        $$=dim_id+1;  
                                                        if(dim_id+1>table[id].array_dim){
                                                            char s[50];
                                                            sprintf(s,"dimension of array %s is %d, gived %d.", table[id].name, table[id].array_dim, dim_id);
                                                            syntax_error(s);
                                                        }
                                                        int p=list_get_product_after_id(table[id].array_size, dim_id);
                                                        gen(lit,0,p);
                                                        gen(opr,0,4);
                                                        if(dim_id>=1){
                                                            gen(opr,0,2);
                                                        }

                                                    }
    |   {$$=0;}
    ;

read_stat:
    READ var array_loc SEMICOLON    {
                                        if($3>=1){
                                            gen(lit,0,table[$2].adr);
                                            gen(opr,0,2);
                                            gen(opr,0,16);
                                            gen(sto,0,0);
                                        }else{
                                            gen(opr,0,16);
                                            gen(sto,0,table[$2].adr);
                                        }
                            
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
    var array_loc   {
                        if($2>=1){
                            gen(lit,0,table[$1].adr);
                            gen(opr,0,2);
                        }
                    }
    BECOMES expression    {
                            if($2>=1){
                                gen(sto,0,0);
                            }else{
                                gen(sto,0,table[$1].adr);
                                /*gen(lod,0,table[$1].adr);*/
                            }
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

/*
condition:
    additive_expr GTR additive_expr     {
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
*/

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
    |term MOD factor    {
                            gen(opr,0,20);
                        }
    |term XOR factor    {
                            gen(opr,0,21);
                        }
    |ODD factor         {
                            gen(opr,0,6);
                        }
    ;

factor:
    LPAREN expression RPAREN {}
    |var  array_loc {
                        if($2>=1){
                            if(table[$1].kind==variable){
                                gen(lit,0,table[$1].adr);
                                gen(opr,0,2);
                                gen(lod,0,0);
                                list_del_last(array_ids);
                            }else{
                                error(0);
                            }
                        }else{
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
            }
    |var SPLUS  {
                    if(table[$1].array==0){
                        gen(lod,0,table[$1].adr);
                        gen(lod,0,table[$1].adr);
                        gen(lit,0,1);
                        gen(opr,0,2);
                        gen(sto,0,table[$1].adr);
                    }else{
                        char s[50];
                        sprintf(s,"%s is an array, not a simple variable.", table[$1].name);
                        syntax_error(s);
                    }
                }
    |var SMINUS {
                    if(table[$1].array==0){
                        gen(lod,0,table[$1].adr);
                        gen(lod,0,table[$1].adr);
                        gen(lit,0,1);
                        gen(opr,0,3);
                        gen(sto,0,table[$1].adr);
                    }else{
                        char s[50];
                        sprintf(s,"%s is an array, not a simple variable.", table[$1].name);
                        syntax_error(s);
                    }
                }
    |SPLUS var  {
                    if(table[$2].array==0){
                        gen(lod,0,table[$2].adr);
                        gen(lit,0,1);
                        gen(opr,0,2);
                        gen(sto,0,table[$2].adr);
                        gen(lod,0,table[$2].adr);
                    }else{
                        char s[50];
                        sprintf(s,"%s is an array, not a simple variable.", table[$2].name);
                        syntax_error(s);
                    }
                }
    |SMINUS var {
                    if(table[$2].array==0){
                        gen(lod,0,table[$2].adr);
                        gen(lit,0,1);
                        gen(opr,0,3);
                        gen(sto,0,table[$2].adr);
                        gen(lod,0,table[$2].adr);
                    }else{
                        char s[50];
                        sprintf(s,"%s is an array, not a simple variable.", table[$2].name);
                        syntax_error(s);
                    }
                }
    |NUM    {
                int num;
                num=$1;
                if(num>AMAX){
                    char s[100];
                    sprintf(s,"integer(%d) should not greater than %d, now 0 instead. ", $1, AMAX);
                    syntax_error(s);
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