%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern YYSTYPE yylval;
%}

%%

[ \t\r\n]+              ;  // Ignore whitespace

[0-9]+                  {
                          yylval.num = atoi(yytext);
                          return NUMBER;
                      }

[a-zA-Z_][a-zA-Z0-9_]*   {
                          if (strcmp(yytext, "print") == 0)
                              return PRINT;
                          yylval.id = strdup(yytext);
                          return IDENTIFIER;
                      }

"="                     return ASSIGN;
";"                     return SEMICOLON;
"("                     return LPAREN;
")"                     return RPAREN;
"+"                     return PLUS;
"-"                     return MINUS;
"*"                     return MUL;
"/"                     return DIV;

.                       {
                          printf("Unknown character: %s\n", yytext);
                          return 0;
                      }

%%

int yywrap() {
    return 1;
}
