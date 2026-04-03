#ifndef TS_H
#define TS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HASH_SIZE 100
#define MAX_IDFLEN 15
#define MAX_TYPLEN 20
#define MAX_VALLEN 50

typedef struct {
    char nom[MAX_IDFLEN];           /* Nom de la variable/constante */
    char type[MAX_TYPLEN];          /* Type : INTEGER, FLOAT */
    char nature[10];                /* Nature : VAR, CONST, TAB */
    char valeur[MAX_VALLEN];        /* Valeur initiale si existe */
    int taille;                     /* Taille du tableau si applicable */
    int ligne_decl;                 /* Ligne de déclaration */
    int est_initialisee;            /* 1 si initialisée, 0 sinon */
    int est_utilisee;               /* 1 si utilisée après déclaration */
} Element;

typedef struct ElementList {
    Element elem;
    struct ElementList *next;
} ElementList;

extern ElementList *table[HASH_SIZE];

/* Initialisation */
void init_table(void);

/* Recherche et insertion */
int recherche_type(const char *nom);
char* get_type(const char *nom);
char* get_nature(const char *nom);
int get_taille(const char *nom);
char* get_valeur(const char *nom);

/* Insertion et modification */
void inserer_type(const char *nom, const char *type);
void inserer_nature(const char *nom, const char *nature);
void inserer_valeur(const char *nom, const char *valeur);
void inserer_taille(const char *nom, int taille);
void maj_code(const char *nom, const char *code);
void marquer_initialisee(const char *nom);
void marquer_utilisee(const char *nom);

/* Insertion générique (pour lexer) */
void inserer(const char *entite, const char *code);

/* Affichage */
void afficher_table(void);

/* Nettoyage */
void liberer_table(void);

/* Vérifications sémantiques */
int est_constant(const char *nom);
int peut_etre_modifiee(const char *nom);
int est_tableau(const char *nom);

#endif