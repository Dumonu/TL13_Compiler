#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "global.h"
#include "symboltbl.h"

symbol* symboltbl = NULL;

int printSymbol(symbol* sym)
{
    if(sym == NULL)
    {
        errno = EFAULT;
        return -1;
    }
    printf("VAR %s AS %s\n", sym->ident, (sym->type == BOOLEAN ? "BOOL" : "INT"));
    return 0;
}

int printTable(void)
{
    if(symboltbl == NULL)
    {
        errno = EFAULT;
        return -1;
    }

    symbol *sym;

    SYMTBL_ITER(sym)
    {
        printSymbol(sym);
    }
    return 0;
}

int printTableC(void)
{
    if(symboltbl == NULL)
    {
        errno = EFAULT;
        return -1;
    }

    symbol *sym;

    SYMTBL_ITER(sym)
    {
        printf("    %s %s;\n", (sym->type == BOOLEAN ? "uint_fast8_t" : "int"),
                sym->ident);
    }
    return 0;
}

int compSym(symbol* a, symbol* b)
{
    return strcmp(a->ident, b->ident);
}

bool inTable(symbol* sym)
{
    if(sym == NULL)
    {
        errno = EFAULT;
        return false;
    }
    symbol* found = NULL;
    HASH_FIND(hh, symboltbl, sym->ident, strlen(sym->ident), found);
    DBG_PRINT("Found? %s\n", found == NULL ? "no" : "yes");
    return found != NULL;
}

// expects ident to point to memory which is allocated
int addSym(symbol* sym)
{
    if(sym == NULL)
    {
        errno = EFAULT;
        return -1;
    }
    if(inTable(sym))
    {
        errno = 0; // I may overhaul part of this system to use my own error messages.
        return -1;
    }

    HASH_ADD_KEYPTR(hh, symboltbl, sym->ident, strlen(sym->ident), sym);
    return 0;
}

symbol* getSym(char* ident)
{
    symbol* found = NULL;
    HASH_FIND(hh, symboltbl, ident, strlen(ident), found);
    return found;
}
