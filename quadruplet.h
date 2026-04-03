#ifndef QUADRUPLET_H
#define QUADRUPLET_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_QUADS 1000

typedef struct {
    char operateur[20];      /* +, -, *, /, =, <, >, <=, >=, ==, !=, AND, OR, NON, JMP, BR, etc */
    char arg1[50];          /* Premier argument */
    char arg2[50];          /* Deuxième argument */
    char resultat[50];      /* Résultat ou label */
} Quadruplet;

/* Gestion des quadruplets */
void init_quadruplets(void);
void ajouter_quad(const char *op, const char *arg1, const char *arg2, const char *res);
void afficher_quadruplets(void);
int get_nb_quads(void);
Quadruplet* get_quad(int index);

/* Génération de temporaires et labels */
char* generer_temp(void);
char* generer_label(void);

/* Génération de quadruplets */
void generer_affect(const char *idf, const char *val);
void generer_operation(const char *op, const char *arg1, const char *arg2, const char *res);
void generer_comparaison(const char *op, const char *arg1, const char *arg2, const char *res);
void generer_saut(const char *label);
void generer_saut_cond(const char *label, const char *condition);

void insert_quad(int pos, const char *op, const char *arg1, const char *arg2, const char *res);
void ajouter_quad_at(int pos, const char *op, const char *arg1, const char *arg2, const char *res);
extern int nb_quads;

/* Optimisation */
void optimiser_quads(void);
void eliminer_inutiles(void);

#endif