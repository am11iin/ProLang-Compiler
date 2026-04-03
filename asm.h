#ifndef ASM_H
#define ASM_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "quadruplet.h"

#define MAX_ASM_LINES 2000

/* Code generation from quadruplets */
void init_asm(void);
void generer_code_asm(void);
void afficher_asm(void);
void generer_prologue(void);
void generer_epilogue(void);

/* Assembly instructions */
void asm_mov(const char *dest, const char *src);
void asm_add(const char *dest, const char *src);
void asm_sub(const char *dest, const char *src);
void asm_mul(const char *dest, const char *src);
void asm_div(const char *dest, const char *src);
void asm_cmp(const char *reg1, const char *reg2);
void asm_jmp(const char *label);
void asm_je(const char *label);
void asm_jne(const char *label);
void asm_jg(const char *label);
void asm_jl(const char *label);
void asm_label(const char *label);
void asm_call(const char *func);
void asm_push(const char *reg);
void asm_pop(const char *reg);
void asm_ret(void);

/* Output line */
void ajouter_asm_line(const char *line);
int get_nb_asm_lines(void);

#endif