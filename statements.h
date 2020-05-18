#ifndef STATEMENTS_H_
#define STATEMENTS_H_

#include "global.h"
#include "symboltbl.h"

enum operator
{
    MULT,
    DIV,
    MOD,
    ADD,
    SUBT,
    EQ,
    NE,
    LT,
    GT,
    LTEQ,
    GTEQ
};

enum stype {
    ASSIGN,
    IFSTMT,
    WHILE,
    WRIINT
};

enum expType {
    VALUE,
    IDENT,
    EXP
};

struct eval {
    enum expType etype;
    int value;
};

struct eident {
    enum expType etype;
    symbol* symbol;
};

struct exp {
    enum expType etype;
    union expression* left;
    enum operator op;
    union expression* right;
};

union expression
{
    enum expType etype;
    struct eval val;
    struct eident ident;
    struct exp exp;
};

struct assignment
{
    enum stype stmttype;
    union statement* next;
    symbol* symbol;
    union expression* exp; // NULL if readInt
};

struct ifstmt
{
    enum stype stmttype;
    union statement* next;
    union expression* exp;
    union statement* do_then;
    union statement* do_else;
};

struct loop
{
    enum stype stmttype;
    union statement* next;
    union expression* exp;
    union statement* do_while;
};

struct writeInt
{
    enum stype stmttype;
    union statement* next;
    union expression* exp;
};

union statement
{
    enum stype stmttype;
    struct assignment assign;
    struct ifstmt ifs;
    struct loop wl;
    struct writeInt wi;
};

extern union statement *stmts;

symtype exptype(union expression* expr);

void printStatementsC(void);

#endif
