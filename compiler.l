%{ 
int wc = 0;        /* word count */ 
%} 

plus        "+"
minus       "-"
times       "*"
slash       "/"
eql         "=="
neq         "!="
les         "<"
leq         "<="
gtr         ">"
geq         ">="
lparen      "("
rparen      ")"
lbrackets   "["
rbrackets   "]"
lbrace      "{"
rbrace      "}"
comma       ","
semicolon   ";"
period      "."
becomes     "="

main        "main"
ifsym       "if"
elsesym     "else"
whilesym    "while"
writesym    "write"
readsym     "read"
dosym       "do"
callsym     "call"
type        "int"|"char"


delim       [" "\n\t]
whitespace  {delim}+
ID          [a-zA-Z_]([a-zA-Z_]|[0-9])*
NUM         ([0-9])+


%% 
{plus}      {printf("plus ");}
{minus}     {printf("minus ");}
{times}     {printf("times ");}
{slash}     {printf("slash ");}
{eql}       {printf("eql ");}
{neq}       {printf("neq ");}
{les}       {printf("les ");}
{leq}       {printf("leq ");}
{gtr}       {printf("gtr ");}
{geq}       {printf("geq ");}
{lparen}    {printf("lparen ");}
{rparen}    {printf("rparen ");}
{lbrackets} {printf("lbrackets ");}
{rbrackets} {printf("rbrackets ");}
{lbrace}    {printf("lbrace ");}
{rbrace}    {printf("rbrace ");}
{comma}     {printf("comma ");}
{semicolon} {printf("semicolon ");}
{period}    {printf("period ");}
{becomes}   {printf("becomes ");}

mainsym     {printf("main");}
{ifsym}     {printf("ifsym ");}
{elsesym}   {printf("elsesym ");}
{whilesym}  {printf("whilesym ");}
{writesym}  {printf("writesym ");}
{readsym}   {printf("readsym ");}
{dosym}     {printf("dosym ");}
{callsym}   {printf("callsym ");}
{type}      {printf("type ");}

{whitespace}    {printf("%s",yytext);}
{ID}            {printf("ID ");}
{NUM}           {printf("NUM ");}
\n|.        { /* gobble up */ }


%% 
int main(int avgs, char *avgr[]) 
{ 
    yyin = fopen(avgr[1], "r");
    if (!yyin)
    {
        return 0;
    }
    int n = yylex(); 
    fclose(yyin);
    return n; 
} 
 
int yywrap(void) 
{ 
    printf("\ndone!\n"); 
    return 1; 
}