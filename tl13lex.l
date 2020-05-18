%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include "symboltbl.h"
#include "statements.h"
#include "tl13parse.tab.h"

char* tokstr[26] = {
    "WHITE",
    "NUM",
    "BOOLLIT",
    "IDENT",
    "LP",
    "RP",
    "ASGN",
    "SC",
    "OP2",
    "OP3",
    "OP4",
    "IF",
    "THEN",
    "ELSE",
    "BEGIN",
    "END",
    "WHILE",
    "DO",
    "PROGRAM",
    "VAR",
    "AS",
    "INT",
    "BOOL",
    "WRITEINT",
    "READINT",
    "EOF"
};
%}
comment \%.*$
white   [ \t\n]+
num     [1-9][0-9]*|0
boollit false|true
ident   [A-Z][A-Z0-9]*
LP      \(
RP      \)
ASGN    :=
SC      ;
OP2     \*|div|mod
OP3     \+|-
OP4     =|!=|<|>|<=|>=
%%
{comment}   ;
{white}     ;
{num}       {
                yylval.intval = atoll(yytext);
                return T_NUM; }
{boollit}   {
                yylval.boolval = (strcmp(yytext, "true") == 0);
                return T_BOOLLIT; }
{ident}     {
                char* id = calloc((strlen(yytext) + 1), sizeof(*id));
                memcpy(id, yytext, strlen(yytext));
                yylval.ident = id;
                return T_IDENT; }
{LP}        { return T_LP; }
{RP}        { return T_RP; }
{ASGN}      { return T_ASGN; }
{SC}        { return T_SC; }
{OP2}       {
                switch(yytext[0])
                {
                    case '*': yylval.op = MULT; break;
                    case 'd': yylval.op = DIV; break;
                    case 'm': yylval.op = MOD; break;
                }
                return T_OP2; }
{OP3}       { 
                switch(yytext[0])
                {
                    case '+': yylval.op = ADD; break;
                    case '-': yylval.op = SUBT; break;
                }
                return T_OP3; }
{OP4}       { 
                switch(yytext[0])
                {
                    case '=': yylval.op = EQ; break;
                    case '!': yylval.op = NE; break;
                    case '<': yylval.op = (yytext[1] == '=' ? LTEQ : LT); break;
                    case '>': yylval.op = (yytext[1] == '=' ? GTEQ : GT); break;
                }
                return T_OP4; }
if          { return T_IF; }
then        { return T_THEN; }
else        { return T_ELSE; }
begin       { return T_BEGIN; }
end         { return T_END; }
while       { return T_WHILE; }
do          { return T_DO; }
program     { return T_PROGRAM; }
var         { return T_VAR; }
as          { return T_AS; }
int         { return T_INT; }
bool        { return T_BOOL; }
writeInt    { return T_WRITEINT; }
readInt     { return T_READINT; }
<<EOF>>     { return -1; }
.           return T_UNKNOWN;
%%
int main()
{
    if(yyparse())
        return 1;
    printf("#include <stdio.h>\n");
    printf("#include <stdint.h>\n\n");
    printf("int main(void){\n");

    printTableC();
    printStatementsC();

    printf("}\n");
    return 0;
}
