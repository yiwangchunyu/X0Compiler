%{ 

#include "compiler.tab.h"
#include "stdio.h"
#include "string.h"
#include "malloc.h"
int line = 0;
int yywrap();
void yyerror(char*);
%} 


whitespace  ([ \t\n])+
ID          [a-zA-Z_]([a-zA-Z_]|[0-9])*
NUM         ([0-9])+


%% 
[ \t]	{;}
[\n]	{line++;}

"+"     {return PLUS;}
"-"     {return MINUS;}
"*"     {return TIMES;}
"/"     {return SLASH;}
"=="       {return EQL;}
"!="       {return NEQ;}
"<"       {return LES;}
"<="       {return LEQ;}
">"       {return GTR;}
">="       {return GEQ;}
"("    {return LPAREN;}
")"    {return RPAREN;}
"[" {return LBRACKETS;}
"]" {return RBRACKETS;}
"{"    {return LBRACE;}
"}"    {return RBRACE;}
","     {return COMMA;}
";" {return SEMICOLON;}
"."    {return PERIOD;}
"="   {return BECOMES;}

"main"     {return MAIN;}
"if"     {return IF;}
"else"   {return ELSE;}
"while"  {return WHILE;}
"write"  {return WRITE;}
"read"   {return READ;}
"do"     {return DO;}
"call"   {return CALL;}
"int"      {return INT;}
"char"      {return CHAR;}

{ID}            {return ID;}
{NUM}           {return NUM;}

.           {   
                yyerror("无效的输入字符:");
                printf("%d\n", *yytext);
            }

%% 

int yywrap(void) 
{
    printf("\ndone!\n"); 
    return 1; 
}