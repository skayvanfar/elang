%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Symbol table
#define HASH_SIZE 100
typedef struct {
    char* name;
    int value;
} Var;

Var symbol_table[HASH_SIZE];

unsigned int hash(const char* str) {
    unsigned int hash = 0;
    while (*str)
        hash = (hash * 31) + *str++;
    return hash % HASH_SIZE;
}

Var* find_var(const char* name) {
    unsigned int index = hash(name);
    if (symbol_table[index].name && strcmp(symbol_table[index].name, name) == 0)
        return &symbol_table[index];
    return NULL;
}

void insert_var(const char* name, int value) {
    unsigned int index = hash(name);
    symbol_table[index].name = strdup(name);
    symbol_table[index].value = value;
}

void yyerror(const char* s);
int yylex(void);
%}

%union {
    int num;
    char* id;
}

// ----- TOKENS -----
%token <num> NUMBER
%token <id> IDENTIFIER
%token PRINT
%token ASSIGN SEMICOLON LPAREN RPAREN PLUS MINUS MUL DIV

%type <num> expr

// ----- OPERATOR PRECEDENCE -----
%left PLUS MINUS
%left MUL DIV

%%
// ----------- GRAMMAR RULES -----------

program:
    program statement
    | /* empty */
    ;

statement:
    IDENTIFIER ASSIGN expr SEMICOLON {
        Var* var = find_var($1);
        if (!var) insert_var($1, $3);
        else var->value = $3;
        printf("%s = %d\n", $1, $3);
    }
    | PRINT LPAREN expr RPAREN SEMICOLON {
        printf("Output: %d\n", $3);
    }
    ;

expr:
    expr PLUS expr   { $$ = $1 + $3; }
    | expr MINUS expr { $$ = $1 - $3; }
    | expr MUL expr   { $$ = $1 * $3; }
    | expr DIV expr   { $$ = $1 / $3; }
    | NUMBER          { $$ = $1; }
    | IDENTIFIER      {
        Var* var = find_var($1);
        if (var) $$ = var->value;
        else {
            fprintf(stderr, "Error: Undefined variable %s\n", $1);
            exit(1);
        }
    }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}
