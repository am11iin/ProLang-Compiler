#include "quadruplet.h"

static Quadruplet quads[MAX_QUADS];
int nb_quads = 0;
int temp_counter = 0;
int label_counter = 0;

/* Initialize quadruplets */
void init_quadruplets(void) {
    nb_quads = 0;
    temp_counter = 0;
    label_counter = 0;
}

/* Generate temporary variable */
char* generer_temp(void) {
    char *temp_name = (char*)malloc(20);
    sprintf(temp_name, "T%d", temp_counter++);
    return temp_name;
}

/* Generate label */
char* generer_label(void) {
    char *label_name = (char*)malloc(20);
    sprintf(label_name, "L%d", label_counter++);
    return label_name;
}

/* Add a quadruplet */
void ajouter_quad(const char *op, const char *arg1, const char *arg2, const char *res) {
    if (nb_quads >= MAX_QUADS) {
        fprintf(stderr, "Erreur : trop de quadruplets\n");
        return;
    }
    
    strncpy(quads[nb_quads].operateur, op ? op : "", 19);
    quads[nb_quads].operateur[19] = '\0';
    
    strncpy(quads[nb_quads].arg1, arg1 ? arg1 : "", 49);
    quads[nb_quads].arg1[49] = '\0';
    
    strncpy(quads[nb_quads].arg2, arg2 ? arg2 : "", 49);
    quads[nb_quads].arg2[49] = '\0';
    
    strncpy(quads[nb_quads].resultat, res ? res : "", 49);
    quads[nb_quads].resultat[49] = '\0';
    
    nb_quads++;
}

/* Display all quadruplets */
void afficher_quadruplets(void) {
    printf("\n/-----------------------------------------------------------\\\n");
    printf("|          CODE INTERMEDIAIRE - Quadruplets (forme 4)      |\n");
    printf("|-----------------------------------------------------------|\n");
    printf("| NUM |     OP      |   ARG1    |   ARG2    |   RESULTAT   |\n");
    printf("|-----------------------------------------------------------|\n");
    
    for (int i = 0; i < nb_quads; i++) {
        printf("| %-3d | %-10s | %-9s | %-9s | %-12s |\n",
               i,
               quads[i].operateur,
               quads[i].arg1,
               quads[i].arg2,
               quads[i].resultat);
    }
    
    printf("\\-----------------------------------------------------------/\n");
    printf("Total quadruplets : %d\n\n", nb_quads);
}

/* Get number of quadruplets */
int get_nb_quads(void) {
    return nb_quads;
}

/* Get quadruplet at index */
Quadruplet* get_quad(int index) {
    if (index >= 0 && index < nb_quads) {
        return &quads[index];
    }
    return NULL;
}

/* Insert a quadruplet at position */
void insert_quad(int pos, const char *op, const char *arg1, const char *arg2, const char *res) {
    if (nb_quads >= MAX_QUADS || pos < 0 || pos > nb_quads) return;
    for(int i = nb_quads; i > pos; i--){
        quads[i] = quads[i-1];
    }
    nb_quads++;
    ajouter_quad_at(pos, op, arg1, arg2, res);
}

/* Add a quadruplet at specific position */
void ajouter_quad_at(int pos, const char *op, const char *arg1, const char *arg2, const char *res) {
    if (pos < 0 || pos >= MAX_QUADS) return;
    strncpy(quads[pos].operateur, op ? op : "", 19);
    quads[pos].operateur[19] = '\0';
    strncpy(quads[pos].arg1, arg1 ? arg1 : "", 49);
    quads[pos].arg1[49] = '\0';
    strncpy(quads[pos].arg2, arg2 ? arg2 : "", 49);
    quads[pos].arg2[49] = '\0';
    strncpy(quads[pos].resultat, res ? res : "", 49);
    quads[pos].resultat[49] = '\0';
}

/* Generate assignment quadruplet */
void generer_affect(const char *idf, const char *val) {
    ajouter_quad("=", val, "", idf);
}

/* Generate operation quadruplet */
void generer_operation(const char *op, const char *arg1, const char *arg2, const char *res) {
    ajouter_quad(op, arg1, arg2, res);
}

/* Generate comparison quadruplet */
void generer_comparaison(const char *op, const char *arg1, const char *arg2, const char *res) {
    ajouter_quad(op, arg1, arg2, res);
}

/* Generate unconditional jump */
void generer_saut(const char *label) {
    ajouter_quad("JMP", "", "", label);
}

/* Generate conditional jump */
void generer_saut_cond(const char *label, const char *condition) {
    ajouter_quad("BR", condition, "", label);
}

/* Simple optimization : eliminate unused quadruplets */
void optimiser_quads(void) {
    /* TODO: Implement optimization rules */
    // For now, just a placeholder
}

void eliminer_inutiles(void) {
    /* TODO: Remove dead code and unused assignments */
}
