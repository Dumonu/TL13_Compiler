%{
/* Prologue */
#include <stdio.h>
#include "global.h"
#include "symboltbl.h"
#include "statements.h"
int yylex(void);
void yyerror(char const *);

%}

%union {
    bool boolval;
    long long intval;
    char* ident;
    enum operator op;
    enum symtype type;

    union expression* exp;
    union statement* stmt;
}

/* Bison declarations */
%define parse.error verbose /* Cool define that prints better error messages */

%token T_NUM
%token T_BOOLLIT
%token T_IDENT
%token T_LP
%token T_RP
%token T_ASGN
%token T_SC
%token T_OP2
%token T_OP3
%token T_OP4
%token T_IF
%token T_THEN
%token T_ELSE
%token T_BEGIN
%token T_END
%token T_WHILE
%token T_DO
%token T_PROGRAM
%token T_VAR
%token T_AS
%token T_INT
%token T_BOOL
%token T_WRITEINT
%token T_READINT
%token T_UNKNOWN

%type<boolval> T_BOOLLIT
%type<intval> T_NUM
%type<ident> T_IDENT
%type<op> T_OP2 T_OP3 T_OP4
%type<type> type
%type<exp> expression simpleExpression term factor
%type<stmt> statementSequence statement assignment ifStatement
    elseClause whileStatement writeInt

%start program

%%
/* Grammar rules */
program:
    T_PROGRAM declarations T_BEGIN statementSequence T_END { stmts = $4; }
;

declarations:
    %empty
    | T_VAR T_IDENT T_AS type T_SC declarations
        { symbol* sym = malloc(sizeof(*sym));
            sym->ident = $2;
            sym->type = $4;
            if(addSym(sym) != 0) {
                yyerror("Error: Symbol Already Declared\n");
                YYERROR;
        } }
;

type: T_INT { $$ = INTEGER; } | T_BOOL { $$ = BOOLEAN; } ;

statementSequence:
    %empty { $$ = NULL; }
    | statement T_SC statementSequence { $1->wi.next = $3; $$ = $1;
        DBG_PRINT("0x%x: { type: %d, next: 0x%x }\n", $1, $1->stmttype, $1->wi.next);
    }
;
statement:
    assignment
    | ifStatement
    | whileStatement
    | writeInt
;

assignment:
    T_IDENT T_ASGN expression
        { union statement* assign = malloc(sizeof(*assign));
            assign->assign.stmttype = ASSIGN;
            assign->assign.next = NULL;
            assign->assign.symbol = getSym($1);
            if(assign->assign.symbol == NULL) {
                yyerror("Error: Symbol Undeclared\n");
                YYERROR;
            }
            assign->assign.exp = $3;
            if(assign->assign.symbol->type == BOOLEAN &&
                    exptype(assign->assign.exp) == INTEGER) {
                yyerror("Error: Assignment of int value to bool\n");
                YYERROR;
            }
            $$ = assign;
        }
    | T_IDENT T_ASGN T_READINT
        { union statement* assign = malloc(sizeof(*assign));
            assign->assign.stmttype = ASSIGN;
            assign->assign.next = NULL;
            assign->assign.symbol = getSym($1);
            if(assign->assign.symbol == NULL) {
                yyerror("Error: Symbol Undeclared\n");
                YYERROR;
            }
            assign->assign.exp = NULL;
            if(assign->assign.symbol->type == BOOLEAN) {
                yyerror("Error: readInt to bool\n");
                YYERROR;
            }
            $$ = assign;
        }
;

ifStatement:
    T_IF expression T_THEN statementSequence elseClause T_END
        { union statement* ifs = malloc(sizeof(*ifs));
            ifs->ifs.stmttype = IFSTMT;
            ifs->ifs.next = NULL;
            ifs->ifs.exp = $2;
            ifs->ifs.do_then = $4;
            ifs->ifs.do_else = $5;
            $$ = ifs;
        }
;

elseClause:
    %empty { $$ = NULL; }
    | T_ELSE statementSequence { $$ = $2; }
;

whileStatement:
    T_WHILE expression T_DO statementSequence T_END
        { union statement* wl = malloc(sizeof(*wl));
            wl->wl.stmttype = WHILE;
            wl->wl.next = NULL;
            wl->wl.exp = $2;
            wl->wl.do_while = $4;
            $$ = wl;
        }
;

writeInt:
    T_WRITEINT expression
        { union statement* wi = malloc(sizeof(*wi));
            wi->wi.stmttype = WRIINT;
            wi->wi.next = NULL;
            wi->wi.exp = $2;
            $$ = wi;
            DBG_PRINT("0x%x: { type: %d, next: 0x%x }\n", wi, wi->stmttype, wi->wi.next);
        }
;

expression:
    simpleExpression { $$ = $1; }
    | simpleExpression T_OP4 simpleExpression
        { union expression* exp = malloc(sizeof(*exp));
            exp->exp.etype = EXP;
            exp->exp.left = $1;
            exp->exp.op = $2;
            exp->exp.right = $3;
            $$ = exp;
        }
;

simpleExpression:
    term T_OP3 term
        { union expression* exp = malloc(sizeof(*exp));
            exp->exp.etype = EXP;
            exp->exp.left = $1;
            exp->exp.op = $2;
            exp->exp.right = $3;
            $$ = exp;
        }
    | term { $$ = $1; }
;

term:
    factor T_OP2 factor
        { union expression* exp = malloc(sizeof(*exp));
            exp->exp.etype = EXP;
            exp->exp.left = $1;
            exp->exp.op = $2;
            exp->exp.right = $3;
            $$ = exp;
        }
    | factor { $$ = $1; }
;

factor:
    T_IDENT
        { union expression* exp = malloc(sizeof(*exp));
            exp->ident.etype = IDENT;
            exp->ident.symbol = getSym($1);
            if(exp->ident.symbol == NULL)
            {
                yyerror("Error: Symbol Undeclared\n");
                YYERROR;
            }
            $$ = exp;
        }
    | T_NUM
        { union expression* exp = malloc(sizeof(*exp));
            exp->val.etype = VALUE;
            exp->val.value = (int)$1;
            if($1 != (int)$1)
            {
                yyerror("Error: literal overflow\n");
                YYERROR;
            }
            $$ = exp;
        }
    | T_BOOLLIT
        { union expression* exp = malloc(sizeof(*exp));
            exp->val.etype = VALUE;
            exp->val.value = (int)$1;
            $$ = exp;
        }
    | T_LP expression T_RP
        { $$ = $2; }
;

%%
/* Epilogue */
void yyerror(char const *estr)
{
    fprintf(stderr, "%s\n", estr);
}
