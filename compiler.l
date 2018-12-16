%{ 

#include "compiler.tab.h"
#include "stdio.h"
#include "string.h"
#include "malloc.h"
int line = 0;
char msg[50];
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
"int"      	{	
				/*yylval.type = (char *)malloc(strlen(yytext)+1);
				strcpy(yylval.type,yytext);*/
				return INT;
			}
"char"      {	
				/*yylval.type = (char *)malloc(strlen(yytext)+1);
				strcpy(yylval.type,yytext);*/
				return CHAR;
			}
'[^'\n]'			{
							yylval.number=(int)(yytext[1]);
							return NUM;
						}

{ID}        {
				yylval.ident=(char *)malloc(strlen(yytext)+1);
				strcpy(yylval.ident,yytext);
				return ID;
			}

{NUM}       {
				yylval.number=atoi(yytext);
				return NUM;
			}

.           {   
				sprintf(msg,"yyerror: unexpected character %s",yytext);
                yyerror(msg);
            }

%% 

int yywrap(void) 
{
    printf("\nlex done!\n"); 
    return 1; 
}
