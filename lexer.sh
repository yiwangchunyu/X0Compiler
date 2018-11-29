lex ./compiler.l && gcc -o compiler ./lex.yy.c && ./compiler ./program.txt >> lexer_out.txt  
cat lexer_out.txt