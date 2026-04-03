
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
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

/* "%code requires" blocks.  */

/* Line 1676 of yacc.c  */
#line 27 "syntax.y"

    typedef struct {
        char type[20];
        char name[50];
    } ExprValue;



/* Line 1676 of yacc.c  */
#line 49 "syntax.tab.h"

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     MC_BEGINPROJECT = 258,
     MC_ENDPROJECT = 259,
     MC_SETUP = 260,
     MC_RUN = 261,
     MC_DEFINE = 262,
     MC_CONST = 263,
     MC_IF = 264,
     MC_THEN = 265,
     MC_ELSE = 266,
     MC_ENDIF = 267,
     MC_LOOP = 268,
     MC_WHILE = 269,
     MC_ENDLOOP = 270,
     MC_FOR = 271,
     MC_IN = 272,
     MC_TO = 273,
     MC_ENDFOR = 274,
     MC_AND = 275,
     MC_OR = 276,
     MC_NON = 277,
     MC_INPUT = 278,
     MC_OUTPUT = 279,
     PIPE = 280,
     AFFECT = 281,
     INFEG = 282,
     SUPEG = 283,
     EGAL = 284,
     DIFF = 285,
     IDF = 286,
     MC_INTEGER = 287,
     MC_FLOAT = 288,
     CST_STR = 289,
     CST_INT = 290,
     CST_REEL = 291
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 34 "syntax.y"

    int entier;
    float reel;
    char *str;
    char type[20];     /* Type of expression result */
    ExprValue expr;   /* Both type and result name for expressions */



/* Line 1676 of yacc.c  */
#line 112 "syntax.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


