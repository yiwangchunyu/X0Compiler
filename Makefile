all: prog clean

prog:   compiler.l compiler.y
	lex compiler.l
	bison -d compiler.y
	gcc -o compiler  lex.yy.c compiler.tab.c -lm

clean:  
	rm lex.yy.c compiler.tab.c compiler.tab.h
