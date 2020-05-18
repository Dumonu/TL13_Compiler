#include <stdio.h>
#include <stdlib.h>

#include "symboltbl.h"
#include "statements.h"

union statement *stmts;
void printSequence(union statement* seq);
void printExpr(union expression* expr);

int indlvl = 1;

symtype exptype(union expression* expr)
{
    if(expr == NULL)
        return INTEGER; // This is a readInt
    // I'll let integers be set from booleans, because seriously, why not?
    if(expr->etype == VALUE)
        return (expr->val.value == 0 || expr->val.value == 1) ? BOOLEAN : INTEGER;
    if(expr->etype == IDENT)
        return expr->ident.symbol->type;

    return (expr->exp.op <= SUBT) ? INTEGER : BOOLEAN;
}

void indent(void)
{
    for(int i = 0; i < indlvl; ++i)
        printf("    ");
}

void printEval(union expression* expr)
{
    printf("%d", expr->val.value);
}

void printEident(union expression* expr)
{
    printf("%s", expr->ident.symbol->ident);
}

char* oparray[11] = {
    "*",
    "/",
    "%",
    "+",
    "-",
    "==",
    "!=",
    "<",
    ">",
    "<=",
    ">="
};

void printExp(union expression* expr)
{
    printf("(");
    printExpr(expr->exp.left);
    printf(") %s (", oparray[expr->exp.op]);
    printExpr(expr->exp.right);
    printf(")");
}

void (*printE[3])(union expression* expr) = {
    printEval,
    printEident,
    printExp
};

void printExpr(union expression* expr)
{
    DBG_PRINT("Expression Type: %s\n", (exptype(expr) == BOOLEAN ? "bool" : "int"));
    (*printE[expr->etype])(expr);
}

void printAssign(union statement* stmt)
{
    indent();
    if(stmt->assign.exp != NULL)
    {
        printf("%s = ", stmt->assign.symbol->ident);
        printExpr(stmt->assign.exp);
    }
    else
    {
        printf("scanf(\"%%d \", &%s)", stmt->assign.symbol->ident);
    }
    printf(";\n");
}

void printIf(union statement* stmt)
{
    indent();
    printf("if(");
    printExpr(stmt->ifs.exp);
    printf("){\n");
    ++indlvl;
    printSequence(stmt->ifs.do_then);
    --indlvl;
    indent();
    printf("}\n");
    if(stmt->ifs.do_else != NULL)
    {
        indent();
        printf("else {\n");
        ++indlvl;
        printSequence(stmt->ifs.do_else);
        --indlvl;
        indent();
        printf("}\n");
    }
}

void printWhile(union statement* stmt)
{
    indent();
    printf("while(");
    printExpr(stmt->wl.exp);
    printf("){\n");
    ++indlvl;
    printSequence(stmt->wl.do_while);
    --indlvl;
    indent();
    printf("}\n");
}

void printWriteInt(union statement* stmt)
{
    indent();
    printf("printf(\"%%d\\n\", ");
    printExpr(stmt->wi.exp);
    printf(");\n");
}

void (*printStmt[4])(union statement* stmt) = {
    printAssign,
    printIf,
    printWhile,
    printWriteInt
};

void printSequence(union statement* seq)
{
    for(union statement* stmt = seq; stmt != NULL; stmt = stmt->wi.next)
    {
        DBG_PRINT("0x%x: { type: %d, next: 0x%x }\n", stmt, stmt->stmttype, stmt->wi.next);
        (*printStmt[stmt->stmttype])(stmt);
    }
}

void printStatementsC(void)
{
    printSequence(stmts);
}
