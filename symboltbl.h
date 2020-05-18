#ifndef SYMBOLTBL_H_
#define SYMBOLTBL_H_

#include "global.h"
#include "uthash.h"

#define SYMTBL_ITER(sym) symbol* sti_tmp; HASH_ITER(hh, symboltbl, (sym), sti_tmp)

typedef enum symtype {
    BOOLEAN,
    INTEGER
} symtype;

typedef struct symbol {
    char* ident;       // Identifier
    symtype type;

    UT_hash_handle hh;  // hash this struct
} symbol;

extern symbol* symboltbl;

// Printing
int printSymbol(symbol* sym);
int printTable(void);
int printTableC(void);

// Comparison
int compSym(symbol* a, symbol* b);
bool inTable(symbol* sym);

// Mutation
int addSym(symbol* sym);
symbol* getSym(char* ident);

#endif
