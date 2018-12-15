/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ID = 258,
    NUM = 259,
    PLUS = 260,
    MINUS = 261,
    TIMES = 262,
    SLASH = 263,
    EQL = 264,
    NEQ = 265,
    LES = 266,
    LEQ = 267,
    GTR = 268,
    GEQ = 269,
    LPAREN = 270,
    RPAREN = 271,
    LBRACKETS = 272,
    RBRACKETS = 273,
    LBRACE = 274,
    RBRACE = 275,
    COMMA = 276,
    SEMICOLON = 277,
    PERIOD = 278,
    BECOMES = 279,
    MAIN = 280,
    IF = 281,
    ELSE = 282,
    WHILE = 283,
    WRITE = 284,
    READ = 285,
    DO = 286,
    CALL = 287,
    INT = 288,
    CHAR = 289
  };
#endif
/* Tokens.  */
#define ID 258
#define NUM 259
#define PLUS 260
#define MINUS 261
#define TIMES 262
#define SLASH 263
#define EQL 264
#define NEQ 265
#define LES 266
#define LEQ 267
#define GTR 268
#define GEQ 269
#define LPAREN 270
#define RPAREN 271
#define LBRACKETS 272
#define RBRACKETS 273
#define LBRACE 274
#define RBRACE 275
#define COMMA 276
#define SEMICOLON 277
#define PERIOD 278
#define BECOMES 279
#define MAIN 280
#define IF 281
#define ELSE 282
#define WHILE 283
#define WRITE 284
#define READ 285
#define DO 286
#define CALL 287
#define INT 288
#define CHAR 289

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 30 "compiler.y" /* yacc.c:1909  */

char *ident;
int number;

#line 127 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
