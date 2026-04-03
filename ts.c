#include "ts.h"

ElementList *table[HASH_SIZE];

int hash(const char *str) {
    unsigned int h = 0;
    while (*str) h = (h * 31 + (unsigned char)*str++) % HASH_SIZE;
    return h;
}

/* Initialize symbol table */
void init_table(void) {
    for (int i = 0; i < HASH_SIZE; i++) table[i] = NULL;
}

/* Search for an element in the symbol table */
int recherche_type(const char *nom) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) return 1;
        p = p->next;
    }
    return 0;
}

/* Get type of an identifier */
char* get_type(const char *nom) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) return p->elem.type;
        p = p->next;
    }
    return "unknown";
}

/* Get nature of an identifier (VAR, CONST, TAB) */
char* get_nature(const char *nom) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) return p->elem.nature;
        p = p->next;
    }
    return "unknown";
}

/* Get array size */
int get_taille(const char *nom) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) return p->elem.taille;
        p = p->next;
    }
    return -1;
}

/* Get value if initialized */
char* get_valeur(const char *nom) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) return p->elem.valeur;
        p = p->next;
    }
    return "";
}

/* Insert or update type */
void inserer_type(const char *nom, const char *type) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) {
            strncpy(p->elem.type, type, MAX_TYPLEN - 1);
            p->elem.type[MAX_TYPLEN - 1] = '\0';
            return;
        }
        p = p->next;
    }
    
    /* Add new entry */
    ElementList *new_elem = (ElementList*)malloc(sizeof(ElementList));
    if (!new_elem) return;
    strncpy(new_elem->elem.nom, nom, MAX_IDFLEN - 1);
    new_elem->elem.nom[MAX_IDFLEN - 1] = '\0';
    strncpy(new_elem->elem.type, type, MAX_TYPLEN - 1);
    new_elem->elem.type[MAX_TYPLEN - 1] = '\0';
    strcpy(new_elem->elem.nature, "VAR");
    strcpy(new_elem->elem.valeur, "");
    new_elem->elem.taille = 0;
    new_elem->elem.ligne_decl = 0;
    new_elem->elem.est_initialisee = 0;
    new_elem->elem.est_utilisee = 0;
    new_elem->next = table[h];
    table[h] = new_elem;
}

/* Set nature of identifier */
void inserer_nature(const char *nom, const char *nature) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) {
            strncpy(p->elem.nature, nature, 9);
            p->elem.nature[9] = '\0';
            return;
        }
        p = p->next;
    }
}

/* Insert value for an identifier */
void inserer_valeur(const char *nom, const char *valeur) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) {
            strncpy(p->elem.valeur, valeur, MAX_VALLEN - 1);
            p->elem.valeur[MAX_VALLEN - 1] = '\0';
            p->elem.est_initialisee = 1;
            return;
        }
        p = p->next;
    }
}

/* Insert array size */
void inserer_taille(const char *nom, int taille) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) {
            p->elem.taille = taille;
            strncpy(p->elem.nature, "TAB", 9);
            return;
        }
        p = p->next;
    }
}

/* Mark as initialized */
void marquer_initialisee(const char *nom) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) {
            p->elem.est_initialisee = 1;
            return;
        }
        p = p->next;
    }
}

/* Mark as used */
void marquer_utilisee(const char *nom) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) {
            p->elem.est_utilisee = 1;
            return;
        }
        p = p->next;
    }
}

/* Update code field (var, const, tab) */
void maj_code(const char *nom, const char *code) {
    int h = hash(nom);
    ElementList *p = table[h];
    while (p) {
        if (strcmp(p->elem.nom, nom) == 0) {
            strncpy(p->elem.nature, code, 9);
            p->elem.nature[9] = '\0';
            return;
        }
        p = p->next;
    }
}

/* Generic insert function (for lexer) */
void inserer(const char *entite, const char *code) {
    if (!recherche_type(entite)) {
        inserer_type(entite, "");
        maj_code(entite, code);
    }
}

/* Check if identifier is a constant */
int est_constant(const char *nom) {
    return strcmp(get_nature(nom), "CONST") == 0;
}

/* Check if identifier can be modified */
int peut_etre_modifiee(const char *nom) {
    return !est_constant(nom);
}

/* Check if identifier is an array */
int est_tableau(const char *nom) {
    return strcmp(get_nature(nom), "TAB") == 0;
}

/* Display symbol table */
void afficher_table(void) {
    printf("\n/-----------------------------------------------------------------------\\\n");
    printf("|            TABLE DES SYMBOLES - ProLang Compiler                     |\n");
    printf("|-----------------------------------------------------------------------|\n");
    printf("| %-14s| %-10s| %-8s| %-15s| %-6s| %-6s |\n", 
           "Nom", "Type", "Nature", "Valeur", "Taille", "Init");
    printf("|-----------------------------------------------------------------------|\n");
    
    for (int i = 0; i < HASH_SIZE; i++) {
        ElementList *p = table[i];
        while (p) {
            printf("| %-14s| %-10s| %-8s| %-15s| %-6d| %-6s |\n",
                   p->elem.nom,
                   p->elem.type,
                   p->elem.nature,
                   p->elem.valeur,
                   p->elem.taille,
                   p->elem.est_initialisee ? "OUI" : "NON");
            p = p->next;
        }
    }
    
    printf("\\-----------------------------------------------------------------------/\n");
    int count = 0;
    for (int i = 0; i < HASH_SIZE; i++) {
        ElementList *p = table[i];
        while (p) { count++; p = p->next; }
    }
    printf("Total d'elements : %d\n\n", count);
}

/* Free memory (cleanup) */
void liberer_table(void) {
    for (int i = 0; i < HASH_SIZE; i++) {
        ElementList *p = table[i];
        while (p) {
            ElementList *next = p->next;
            free(p);
            p = next;
        }
        table[i] = NULL;
    }
}
