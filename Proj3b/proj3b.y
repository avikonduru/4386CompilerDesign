%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
    int yylex();
    int yyerror(const char *p) {
	printf("%s", p);
    }

    enum types {
	INT_VAR_T,
	BOOL_VAR_T,
    };

    struct symrec
    {
	char *name;
	enum types type; /*0 = int; 1 = bool;*/
	union {
	    int integer;
	    int boolean;
	} value;
	struct symrec *next; /*pointer to the next symrec*/
    } *sym_table; /*standard says that file scope = 0*/

    void add_symbol(enum types type, char *name, int value) {
	struct symrec *entry = sym_table;
	while(entry != NULL) {
	    entry = entry->next;
	}
	entry = malloc(sizeof(struct symrec));
	entry->name = strdup(name);
	entry->type = type;
	if(type == INT_VAR_T) {
	    entry->value.integer = value;
	} else {
	    entry->value.boolean = value;
	}
	entry->next = NULL;
    }


    /*TODO: create a struct for every nonterminal*/
    /*t short for type, v short for value*/

    struct statementSequence_t;
    struct expression_t;
    struct factor_t {
	union {
	    char *identifier;
	    int *num;
	    int *boollit;
	    struct expression_t *expression_v;
	};
    };
    struct term_t {
	union {
	    struct factor_t *factor_v;
	    struct {
		struct factor_t *op2_L;
		struct factor_t *op2_R;
	    } op2;
	};
    };
    struct simpleExpression_t {
	union {
	    struct term_t *term_v;
	    struct {
		struct term_t *op3_L;
		struct term_t *op3_R;
	    } op3;
	};
    };
    struct expression_t {
	union {
	    struct simpleExpression_t *simpleExpression_v;
	    struct {
		struct simpleExpression_t *op4_L;
		struct simpleExpression_t *op4_R;
	    } op4;
	};  
    };
    struct writeInt_t {
	struct expression_t *expression_v;
    };
    struct whileStatement_t {
	struct expression_t *expression_v;
	struct statementSequence_t *statementSequence_v;
    };
    struct elseClause_t {
	struct statementSequence_t *statementSequence_v;
    };
    struct ifStatement_t {
	struct expression_t *expression_v;
	struct statementSequence_t *statementSequence_v;
	struct elseClause_t *elseClause_v;
    };
    struct assignment_t {
	char *identifier;
	union {
	    int readInt_v; /*to be fed via stdin*/
	    struct expression_t *expression_v;
	};
    };
    struct statement_t {
	union {
	    struct assignment_t *assignment_v;
	    struct ifStatement_t *ifStatement_v;
	    struct whileStatement_t *whileStatement_v;
	    struct writeInt_t *writeInt_v;
	};
    };
    struct statementSequence_t {
	struct statement_t *statement_v;
	struct statementSequence_t *satementSequence_v; /*next ptr*/
    };
    struct declarations_t {
	char *identifier;
	enum types type;
	struct declarations_t *declarations_v; /*next ptr*/
    };
    struct program_t {
	struct declarations_t *declarations_v;
	struct statementSequence_t *statementSequence_v;
    };
    
    %}

/*datatypes*/
%union {
    char *sym;
    int num;
    struct program_t *program_u;
    struct declarations_t *declarations_u;
    struct statementSequence_t *statementSequence_u;
    struct statement_t *statement_u;
    struct assignment_t *assignment_u;
    struct ifStatement_t *ifStatement_u;
    struct elseClause_t *elseClause_u;
    struct whileStatement_t *whileStatement_u;
    struct writeInt_t *writeInt_u;
    struct expression_t *expression_u;
    struct simpleExpression_t *simpleExpression_u;
    struct term_t *term_u;
    struct factor_t *factor_u;
};
			
%token <num> NUM;
%token <sym> BOOLLIT;
%token <sym> IDENT;
%token <sym> LP RP ASGN SC OP2 OP3 OP4 IF THEN ELSE BEGN END WHILE DO PROGRAM VAR AS INT BOOL WRITEINT READINT;

%type <program_u> program;
%type <declarations_u> declarations;
%type <statementSequence_u> statementSequence;
%type <statement_u> statement;
%type <assignment_u> assignment;
%type <ifStatement_u> ifStatement;
%type <elseClause_u> elseClause;
%type <whileStatement_u> whileStatement;
%type <writeInt_u> writeInt;
%type <expression_u> expression;
%type <simpleExpression_u> simpleExpression;
%type <term_u> term;
%type <factor_u> factor;

%% /*grammar*/
program: PROGRAM declarations BEGN statementSequence END {printf("program\n"); }
;
declarations: VAR IDENT AS type SC declarations {printf("declarations\n"); }
| /*empty*/ {printf("declarations: empty\n"); }

type: INT {printf("type: int\n");}
| BOOL {printf("type: bool\n"); }
;
statementSequence: statement SC statementSequence {printf("statementSequence: statement\n"); }
| /*empty*/ {printf("statementSequence: empty\n"); }
;
statement: assignment {printf("statement: assignment\n"); }
| ifStatement {printf("statement: ifStatement\n"); }
| whileStatement {printf("statement: whileStatement\n"); }
| writeInt {printf("statement: writeInt\n"); }
;
assignment: IDENT ASGN expression {printf("assignment: expression\n"); }
| IDENT ASGN READINT {printf("assignment: readInt\n"); }
;
ifStatement: IF expression THEN statementSequence elseClause END {printf("ifStatement\n"); }
;
elseClause: ELSE statementSequence {printf("elseClause: else\n"); }
| /*empty*/ {printf("elseClause: empty\n"); }
;
whileStatement: WHILE expression DO statementSequence END {printf("whileStatement\n"); }
;
writeInt: WRITEINT expression {printf("writeInt\n"); }
;
expression: simpleExpression {printf("expression: simpleExpression\n"); }
| simpleExpression OP4 simpleExpression {printf("expression: OP4\n"); }
;
simpleExpression: term OP3 term {printf("simpleExpression: OP3\n"); }
| term {printf("simpleExpression: term\n"); }
;
term: factor OP2 factor {printf("term: OP2\n");}
| factor {printf("term: factor\n"); }
;
factor: IDENT {printf("factor: IDENT: %s\n", $1); }
| NUM {printf("factor: NUM: %d\n", $1); }
| BOOLLIT {printf("factor: BOOLLIT: %s\n", $1); }
| LP expression RP {printf("factor: expression\n"); }
;

%% /*program*/
int main() {
    yyparse();
    return 0;
}
