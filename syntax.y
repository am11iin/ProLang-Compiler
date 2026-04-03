%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "ts.h"
#include "quadruplet.h"
#include "asm.h"

extern int ligne;
extern int colonne;
extern void yyerror(const char *msg);
extern char* generer_temp(void);
extern char* generer_label(void);
int yylex(void);

char type_courant[20];
int yydebug = 0;
int error_count = 0;
int start_index;

/* Buffer for liste_idf */
#define MAX_LISTE_IDF 100
char liste_idf_courant[MAX_LISTE_IDF][20];
int nb_idf_courant = 0;
%}

%code requires {
    typedef struct {
        char type[20];
        char name[50];
    } ExprValue;
}

%union {
    int entier;
    float reel;
    char *str;
    char type[20];     /* Type of expression result */
    ExprValue expr;   /* Both type and result name for expressions */
}

%token MC_BEGINPROJECT MC_ENDPROJECT MC_SETUP MC_RUN
%token MC_DEFINE MC_CONST MC_IF MC_THEN MC_ELSE MC_ENDIF
%token MC_LOOP MC_WHILE MC_ENDLOOP MC_FOR MC_IN MC_TO MC_ENDFOR
%token MC_AND MC_OR MC_NON MC_INPUT MC_OUTPUT PIPE AFFECT INFEG SUPEG EGAL DIFF
%token <str> IDF MC_INTEGER MC_FLOAT CST_STR
%token <entier> CST_INT
%token <reel> CST_REEL

/* Precedences et associativité */
%left MC_OR
%left MC_AND
%right MC_NON
%left '<' '>' INFEG SUPEG EGAL DIFF
%left '+' '-'
%left '*' '/'

%start programme

%type <expr> expression
%type <entier> before_if before_loop before_for

%%

programme 
    : MC_BEGINPROJECT IDF ';' MC_SETUP ':' declarations MC_RUN ':' '{' instructions '}' MC_ENDPROJECT ';'
    { 
        printf("\n*** Analyse reussie ***\n");
    }
;

declarations 
    : /* vide */
    | declarations declaration
;

declaration 
    : MC_DEFINE corps_declaration ';'
    | MC_CONST IDF ':' type '=' expression ';'
      {
          if (recherche_type($2) == 1) {
              printf("Semantique, ligne %d, colonne %d, Double declaration : %s\n", ligne, colonne, $2);
          } else if (strcmp(type_courant, $6.type) != 0) {
              printf("Semantique, ligne %d, colonne %d, Type incompatible pour la constante\n", ligne, colonne);
          } else {
              inserer_type($2, type_courant);
              inserer_nature($2, "CONST");
              marquer_initialisee($2);
          }
      }
;

corps_declaration
    : IDF ':' type
    {
        if (recherche_type($1) == 1) {
            printf("Semantique, ligne %d, colonne %d, Double declaration : %s\n", ligne, colonne, $1);
        } else {
            inserer_type($1, type_courant);
            inserer_nature($1, "VAR");
        }
    }
    | liste_idf ':' type
    {
        for (int i = 0; i < nb_idf_courant; i++) {
            if (recherche_type(liste_idf_courant[i]) == 1) {
                printf("Semantique, ligne %d, colonne %d, Double declaration : %s\n", ligne, colonne, liste_idf_courant[i]);
            } else {
                inserer_type(liste_idf_courant[i], type_courant);
                inserer_nature(liste_idf_courant[i], "VAR");
            }
        }
        nb_idf_courant = 0;
    }
    | IDF ':' type '=' expression
      {
          if (recherche_type($1) == 1) {
              printf("Semantique, ligne %d, colonne %d, Double declaration : %s\n", ligne, colonne, $1);
          } else if (strcmp(type_courant, $5.type) != 0) {
              printf("Semantique, ligne %d, colonne %d, Type incompatible pour l'initialisation\n", ligne, colonne);
          } else {
              inserer_type($1, type_courant);
              inserer_nature($1, "VAR");
              marquer_initialisee($1);
          }
      }
    | IDF ':' '[' type ';' CST_INT ']'
      {
          if (recherche_type($1) == 1) {
              printf("Semantique, ligne %d, colonne %d, Double declaration : %s\n", ligne, colonne, $1);
          } else {
              if ($6 <= 0) printf("Semantique, ligne %d, colonne %d, Taille tableau invalide : %d\n", ligne, colonne, $6);
              inserer_type($1, type_courant);
              inserer_nature($1, "TAB");
              inserer_taille($1, $6);
          }
      }
;

liste_idf 
    : IDF PIPE IDF
    {
        nb_idf_courant = 0;
        strcpy(liste_idf_courant[nb_idf_courant++], $1);
        strcpy(liste_idf_courant[nb_idf_courant++], $3);
    }
    | liste_idf PIPE IDF 
    { 
        strcpy(liste_idf_courant[nb_idf_courant++], $3);
    }
;

type 
    : MC_INTEGER { strcpy(type_courant, "INTEGER"); }
    | MC_FLOAT   { strcpy(type_courant, "FLOAT"); }
;

instructions 
    : /* vide */
    | instructions instruction
    | instructions error
;

instruction 
    : IDF AFFECT expression ';'
    {
        if (recherche_type($1) == 0) {
            printf("Semantique, ligne %d, colonne %d, Variable non declaree : %s\n", ligne, colonne, $1);
        } else if (est_constant($1)) {
            printf("Semantique, ligne %d, colonne %d, Modification de constante : %s\n", ligne, colonne, $1);
        } else {
            marquer_utilisee($1);
            ajouter_quad("=", $3.name, "", $1);
        }
    }
    | IDF '[' expression ']' AFFECT expression ';'
    {
        if (recherche_type($1) == 0) {
            printf("Semantique, ligne %d, colonne %d, Variable non declaree : %s\n", ligne, colonne, $1);
        } else if (strcmp(get_nature($1), "TAB") != 0) {
            printf("Semantique, ligne %d, colonne %d, %s n'est pas un tableau\n", ligne, colonne, $1);
        } else if (strcmp($3.type, "INTEGER") != 0) {
            printf("Semantique, ligne %d, colonne %d, Index de tableau doit être entier\n", ligne, colonne);
        } else if (strcmp(get_type($1), $6.type) != 0) {
            printf("Semantique, ligne %d, colonne %d, Type incompatible pour l'assignation du tableau\n", ligne, colonne);
        } else {
            marquer_utilisee($1);
            ajouter_quad("=[]", $6.name, $3.name, $1);
        }
    }
    | if_stmt
    | loop_stmt
    | MC_OUTPUT '(' args_out ')' ';'
    {
        ajouter_quad("OUTPUT", "", "", "");
    }
    | MC_INPUT '(' IDF ')' ';'
    {
        if (recherche_type($3) == 0) {
            printf("Semantique, ligne %d, colonne %d, Variable non declaree : %s\n", ligne, colonne, $3);
        } else {
            marquer_utilisee($3);
            ajouter_quad("INPUT", "", "", $3);
        }
    }
;

before_if : { $$ = nb_quads; } ;

before_loop : { $$ = nb_quads; } ;

before_for : { $$ = nb_quads; } ;

if_stmt 
    : before_if MC_IF '(' expression ')' MC_THEN ':' '{' instructions '}' MC_ELSE '{' instructions '}' MC_ENDIF ';'
    {
        int start_index = $1;
        char *label_else = generer_label();
        char *label_endif = generer_label();
        insert_quad(start_index, "BZ", $4.name, "", label_else);
        ajouter_quad("JMP", "", "", label_endif);
        ajouter_quad("LABEL", "", "", label_else);
        ajouter_quad("LABEL", "", "", label_endif);
        if (strcmp($4.type, "INTEGER") != 0) printf("Semantique, ligne %d, Condition doit être de type entier\n", ligne);
    }
    | before_if MC_IF '(' expression ')' MC_THEN ':' '{' instructions '}' MC_ENDIF ';'
    {
        int start_index = $1;
        char *label_endif = generer_label();
        insert_quad(start_index, "BZ", $4.name, "", label_endif);
        ajouter_quad("LABEL", "", "", label_endif);
        if (strcmp($4.type, "INTEGER") != 0) printf("Semantique, ligne %d, Condition doit être de type entier\n", ligne);
    }
;

loop_stmt 
    : before_loop MC_LOOP MC_WHILE '(' expression ')' '{' instructions '}' MC_ENDLOOP ';'
    {
        int start_index = $1;
        char *label_debut = generer_label();
        char *label_fin = generer_label();
        insert_quad(start_index, "LABEL", "", "", label_debut);
        insert_quad(start_index + 1, "BZ", $5.name, "", label_fin);
        ajouter_quad("JMP", "", "", label_debut);
        ajouter_quad("LABEL", "", "", label_fin);
        if (strcmp($5.type, "INTEGER") != 0) printf("Semantique, ligne %d, Condition doit être de type entier\n", ligne);
    }
    | before_for MC_FOR IDF MC_IN expression MC_TO expression '{' instructions '}' MC_ENDFOR ';'
    {
        int start_index = $1;
        if (recherche_type($3) == 0) {
            printf("Semantique, ligne %d, colonne %d, Variable non declaree : %s\n", ligne, colonne, $3);
        }
        if (strcmp($5.type, "INTEGER") != 0) printf("Semantique, ligne %d, Debut de boucle doit être entier\n", ligne);
        if (strcmp($7.type, "INTEGER") != 0) printf("Semantique, ligne %d, Fin de boucle doit être entier\n", ligne);
        char *label_debut = generer_label();
        char *label_fin = generer_label();
        insert_quad(start_index, "=", $5.name, "", $3);  /* init counter */
        insert_quad(start_index + 1, "LABEL", "", "", label_debut);
        char *temp_cmp = generer_temp();
        insert_quad(start_index + 2, ">", $3, $7.name, temp_cmp);
        insert_quad(start_index + 3, "BZ", temp_cmp, "", label_fin);
        char *temp_inc = generer_temp();
        ajouter_quad("+", $3, "1", temp_inc);
        ajouter_quad("=", temp_inc, "", $3);
        ajouter_quad("JMP", "", "", label_debut);
        ajouter_quad("LABEL", "", "", label_fin);
    }
;

expression 
    : expression '+' expression
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("+", $1.name, $3.name, temp);
    }
    | expression '-' expression
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("-", $1.name, $3.name, temp);
    }
    | expression '*' expression
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("*", $1.name, $3.name, temp);
    }
    | expression '/' expression
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("/", $1.name, $3.name, temp);
    }
    | expression '<' expression 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("<", $1.name, $3.name, temp);
    }
    | expression '>' expression 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad(">", $1.name, $3.name, temp);
    }
    | expression INFEG expression 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("<=", $1.name, $3.name, temp);
    }
    | expression SUPEG expression 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad(">=", $1.name, $3.name, temp);
    }
    | expression EGAL expression 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("==", $1.name, $3.name, temp);
    }
    | expression DIFF expression 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("!=", $1.name, $3.name, temp);
    }
    | expression MC_AND expression 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("AND", $1.name, $3.name, temp);
    }
    | expression MC_OR expression 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
        ajouter_quad("OR", $1.name, $3.name, temp);
    }
    | MC_NON '(' expression ')' 
    {
        char *temp = generer_temp();
        strcpy($$.name, temp);
        strcpy($$.type, $3.type);
        ajouter_quad("NON", $3.name, "", temp);
    }
    | '(' expression ')' 
    {
        strcpy($$.type, $2.type);
        strcpy($$.name, $2.name);
    }
    | IDF '[' expression ']'
    {
        if (recherche_type($1) == 0) {
            printf("Semantique, ligne %d, colonne %d, Variable non declaree : %s\n", ligne, colonne, $1);
        } else if (strcmp(get_nature($1), "TAB") != 0) {
            printf("Semantique, ligne %d, colonne %d, %s n'est pas un tableau\n", ligne, colonne, $1);
        } else if (strcmp($3.type, "INTEGER") != 0) {
            printf("Semantique, ligne %d, colonne %d, Index de tableau doit être entier\n", ligne, colonne);
        } else {
            marquer_utilisee($1);
            char *temp = generer_temp();
            strcpy($$.name, temp);
            strcpy($$.type, get_type($1));
            ajouter_quad("[]", $1, $3.name, temp);
        }
    }
    | IDF 
    {
        if (recherche_type($1) == 0) {
            printf("Semantique, ligne %d, colonne %d, Variable non declaree : %s\n", ligne, colonne, $1);
        } else {
            marquer_utilisee($1);
            strcpy($$.name, $1);
            strcpy($$.type, get_type($1));
        }
    }
    | CST_INT 
    {
        char temp[20];
        sprintf(temp, "%d", $1);
        strcpy($$.name, temp);
        strcpy($$.type, "INTEGER");
    }
    | CST_REEL 
    {
        char temp[20];
        sprintf(temp, "%f", $1);
        strcpy($$.name, temp);
        strcpy($$.type, "FLOAT");
    }
    | CST_STR 
    {
        strcpy($$.name, "STRING");
        strcpy($$.type, "STRING");
    } 
;

args_out : arg | args_out ',' arg ;
arg : expression ;

%%

void yyerror(const char *msg) {
    error_count++;
    printf("Syntaxique, ligne %d, colonne %d, %s\n", ligne, colonne, msg);
}

int main() {
    yydebug = 0;
    init_table();
    init_quadruplets();
    init_asm();
    int result = yyparse();
    if (result == 0) {
        optimiser_quads();
        eliminer_inutiles();
        optimiser_quads();
        eliminer_inutiles();
        afficher_table();
        afficher_quadruplets();
        generer_code_asm();
        afficher_asm();
    } else {
        printf("Erreurs de syntaxe ou semantique, pas de generation de code.\n");
    }
    return result;
}