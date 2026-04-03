%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "syntax.tab.h"

extern YYSTYPE yylval;
int ligne = 1;
int colonne = 1;
%}

%%

"BeginProject"  { colonne += yyleng; return MC_BEGINPROJECT; }
"EndProject"    { colonne += yyleng; return MC_ENDPROJECT; }
"Setup"         { colonne += yyleng; return MC_SETUP; }
"Run"           { colonne += yyleng; return MC_RUN; }
"define"        { colonne += yyleng; return MC_DEFINE; }
"const"         { colonne += yyleng; return MC_CONST; }
"integer"       { yylval.str = strdup(yytext); colonne += yyleng; return MC_INTEGER; }
"float"         { yylval.str = strdup(yytext); colonne += yyleng; return MC_FLOAT; }
"if"            { colonne += yyleng; return MC_IF; }
"then"          { colonne += yyleng; return MC_THEN; }
"else"          { colonne += yyleng; return MC_ELSE; }
"endIf"         { colonne += yyleng; return MC_ENDIF; }
"loop"          { colonne += yyleng; return MC_LOOP; }
"while"         { colonne += yyleng; return MC_WHILE; }
"endloop"       { colonne += yyleng; return MC_ENDLOOP; }
"for"           { colonne += yyleng; return MC_FOR; }
"in"            { colonne += yyleng; return MC_IN; }
"to"            { colonne += yyleng; return MC_TO; }
"endfor"        { colonne += yyleng; return MC_ENDFOR; }
"input"         { colonne += yyleng; return MC_INPUT; }
"output"        { colonne += yyleng; return MC_OUTPUT; }
"AND"           { colonne += yyleng; return MC_AND; }
"OR"            { colonne += yyleng; return MC_OR; }
"NON"           { colonne += yyleng; return MC_NON; }

"//"[^\n]*      { colonne += yyleng; }
"/*"           {
    int c, prev = 0;
    while ((c = input()) != 0) {
        if (prev == '*' && c == '/') break;
        if (c == '\n') { ligne++; colonne = 1; }
        else { colonne++; }
        prev = c;
    }
}

"<-"            { colonne += yyleng; return AFFECT; }
"<="            { colonne += yyleng; return INFEG; }
">="            { colonne += yyleng; return SUPEG; }
"=="            { colonne += yyleng; return EGAL; }
"!="            { colonne += yyleng; return DIFF; }
"="             { colonne += yyleng; return '='; }
"+"             { colonne += yyleng; return '+'; }
"-"             { colonne += yyleng; return '-'; }
"*"             { colonne += yyleng; return '*'; }
"/"             { colonne += yyleng; return '/'; }
">"             { colonne += yyleng; return '>'; }
"<"             { colonne += yyleng; return '<'; }

";"             { colonne += yyleng; return ';'; }
":"             { colonne += yyleng; return ':'; }
"["             { colonne += yyleng; return '['; }
"]"             { colonne += yyleng; return ']'; }
"("             { colonne += yyleng; return '('; }
")"             { colonne += yyleng; return ')'; }
","             { colonne += yyleng; return ','; }
"|"             { colonne += yyleng; return PIPE; }
"{"             { colonne += yyleng; return '{'; }
"}"             { colonne += yyleng; return '}'; }

[0-9]+\.[0-9]+  { yylval.reel = atof(yytext); colonne += yyleng; return CST_REEL; }
-?[0-9]+          { 
    yylval.entier = atoi(yytext); 
    if (yylval.entier < -32768 || yylval.entier > 32767) {
        printf("Erreur lexicale, ligne %d, colonne %d, Valeur entier hors limites : %d\n", ligne, colonne, yylval.entier);
        colonne += yyleng;
        // skip
    } else {
        colonne += yyleng; 
        return CST_INT; 
    }
}

\"[^\"]*\"       { yylval.str = strdup(yytext); colonne += yyleng; return CST_STR; }

[a-zA-Z][a-zA-Z0-9_]* {
    if (yyleng > 14) {
        printf("Erreur lexicale, ligne %d, colonne %d, IDF trop long : %s\n", ligne, colonne, yytext);
        colonne += yyleng;
        // skip
    } else if (yytext[yyleng-1] == '_') {
        printf("Erreur lexicale, ligne %d, colonne %d, IDF se termine par _ : %s\n", ligne, colonne, yytext);
        colonne += yyleng;
        // skip
    } else {
        int has_consec = 0;
        for (int i = 0; i < yyleng-1; i++) {
            if (yytext[i] == '_' && yytext[i+1] == '_') {
                has_consec = 1;
                break;
            }
        }
        if (has_consec) {
            printf("Erreur lexicale, ligne %d, colonne %d, IDF a des _ consecutifs : %s\n", ligne, colonne, yytext);
            colonne += yyleng;
            // skip
        } else {
            yylval.str = strdup(yytext);
            colonne += yyleng;
            return IDF;
        }
    }
}

"%%"[^\n]*      { colonne += yyleng; }

[ \t\r]+        { colonne += yyleng; }

\n              { ligne++; colonne = 1; }

.               { printf("Erreur lexicale, ligne %d, colonne %d, %s\n", ligne, colonne, yytext); colonne++; }

%%

int yywrap() {
    return 1;
}