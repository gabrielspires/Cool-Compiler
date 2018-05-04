/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%option noyywrap

%{
#include "cool-parse.h"
#include "stringtab.h"
#include "utilities.h"

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

bool string_error;
unsigned int string_buf_left;
unsigned int comment = 0;

int nullCharError(){
	string_error = true;
	yylval.error_msg = "String contains null character";
	return -1;
}

char* backslashCommon(){
	char *b = &yytext[1];
	if (*b == '\n'){
		curr_lineno++;
	}
	return b;
}

int stringWrite(char *str, unsigned int strSize){
	if (strSize < string_buf_left){
		strncpy(string_buf_ptr, str, strSize);
		string_buf_ptr += strSize;
		string_buf_left -= strSize;
		return 0;
	}
	else{
		string_error = true;
		yylval.error_msg = "String constant too long";
		return -1;
	}
}

%}

	/*
	 * Define names for regular expressions here.
	 */

DARROW          =>
ASSIGN          <-
BACKSLASH       [\\]
CASE            [cC][aA][sS][eE]
CLASS           [cC][lL][aA][sS][sS]
DIGIT           [0-9]
ELSE            [eE][lL][sS][eE]
ESAC            [eE][sS][aA][cC]
FALSE           f[aA][lL][sS][eE]
FI              [fF][iI]
IF              [iI][fF]
IN              [iI][nN]
INHERITS        [iI][nN][hH][eE][rR][iI][tT][sS]
ISVOID          [iI][sS][vV][oO][iI][dD]
LE              <=
LEFTPAREN       [(]
LET             [lL][eE][tT]
LOOP            [lL][oO][oO][pP]
NEW             [nN][eE][wW]
NEWLINE         [\n]
NOT             [nN][oO][tT]
NOTCOMMENT      [^\n*(\\]
NOTLEFTPAREN    [^(]
NOTNEWLINE      [^\n]
NOTRIGHTPAREN   [^)]
NOTSTAR         [^*]
NOTSTRING       [^\n\0\\\"]
NULLCH          [\0]
OBJECTID        [a-z][_a-zA-Z0-9]*
OF              [oO][fF]
POOL            [pP][oO][oO][lL]
QUOTES          \"
RIGHTPAREN      [)]
STAR            [*]
THEN            [tT][hH][eE][nN]
TRUE            t[rR][uU][eE]
TYPEID          [A-Z][_a-zA-Z0-9]*
WHILE           [wW][hH][iI][lL][eE]
WHITESPACE      [ \t\r\f\v]+

START_COMMENT   "(*"
END_COMMENT     "*)"
LINE_COMMENT    "--"

%x COMMENT
%x STRING

%%

<INITIAL,COMMENT>{NEWLINE} {
		curr_lineno++;
}

{START_COMMENT} {
	comment++;
	BEGIN(COMMENT);
}

<COMMENT><<EOF>> {
	yylval.error_msg = "EOF in comment";
	BEGIN(INITIAL);
	return (ERROR);
}

<COMMENT>{STAR}/{NOTRIGHTPAREN}    ;
<COMMENT>{LEFTPAREN}/{NOTSTAR}     ;
<COMMENT>{NOTCOMMENT}*             ;

<COMMENT>{BACKSLASH}(.|{NEWLINE}) {
	backslashCommon();
};
<COMMENT>{BACKSLASH}               ;

	/*
	*  Nested comments
	*/

<COMMENT>{START_COMMENT} {
	comment++;
}

<COMMENT>{END_COMMENT} {
	comment--;
	if (comment == 0) {
		BEGIN(INITIAL);
	}
}

<INITIAL>{END_COMMENT} {
	yylval.error_msg = "Unmatched *)";
	return (ERROR);
}

<INITIAL>{LINE_COMMENT}{NOTNEWLINE}*  ;

<INITIAL>{QUOTES} {
	BEGIN(STRING);
	string_buf_ptr = string_buf;
	string_buf_left = MAX_STR_CONST;
	string_error = false;
}

<STRING><<EOF>> {
	yylval.error_msg = "EOF in string constant";
	BEGIN(INITIAL);
	return ERROR;
}

<STRING>{NOTSTRING}* {
	int rc = stringWrite(yytext, strstrSize(yytext));
	if (rc != 0) {
		return (ERROR);
	}
}
<STRING>{NULLCH} {
	nullCharError();
	return (ERROR);
}

<STRING>{NEWLINE} {
	BEGIN(INITIAL);
	curr_lineno++;
	if (string_error == false) {
		yylval.error_msg = "Unterminated string constant";
		return (ERROR);
	}
}
<STRING>{BACKSLASH}(.|{NEWLINE}) {
	char *c = backslashCommon();
	int rc;

	switch (*c) {
		case 'n':
			rc = stringWrite("\n", 1);
			break;
		case 'b':
			rc = stringWrite("\b", 1);
			break;
		case 't':
			rc = stringWrite("\t", 1);
			break;
		case 'f':
			rc = stringWrite("\f", 1);
			break;
		case '\0':
			rc = nullCharError();
			yylval.error_msg = "String contains escaped null character";
			break;
		default:
			rc = stringWrite(c, 1);
	}
	if (rc != 0) {
		return (ERROR);
	}
}
<STRING>{BACKSLASH}             ;

<STRING>{QUOTES} {
	BEGIN(INITIAL);
	if (string_error == false) {
		yylval.symbol = stringtable.add_string(string_buf, string_buf_ptr - string_buf);
		return (STR_CONST);
	}
}

<INITIAL>{DARROW}    { return (DARROW); }
<INITIAL>{ASSIGN}    { return (ASSIGN); }
<INITIAL>{CASE}      { return (CASE); }
<INITIAL>{CLASS}     { return (CLASS); }
<INITIAL>{ELSE}      { return (ELSE); }
<INITIAL>{ESAC}      { return (ESAC); }
<INITIAL>{FI}        { return (FI); }
<INITIAL>{IF}        { return (IF); }
<INITIAL>{INHERITS}  { return (INHERITS); }
<INITIAL>{IN}        { return (IN); }
<INITIAL>{ISVOID}    { return (ISVOID); }
<INITIAL>{LET}       { return (LET); }
<INITIAL>{LE}        { return (LE); }
<INITIAL>{LOOP}      { return (LOOP); }
<INITIAL>{NEW}       { return (NEW); }
<INITIAL>{NOT}       { return (NOT); }
<INITIAL>{OF}        { return (OF); }
<INITIAL>{POOL}      { return (POOL); }
<INITIAL>{THEN}      { return (THEN); }
<INITIAL>{WHILE}     { return (WHILE); }

<INITIAL>{TRUE}      { yylval.boolean = true; return (BOOL_CONST); }
<INITIAL>{FALSE}     { yylval.boolean = false; return (BOOL_CONST); }

<INITIAL>{TYPEID}    { yylval.symbol = stringtable.add_string(yytext); return (TYPEID); }
<INITIAL>{OBJECTID}  { yylval.symbol = stringtable.add_string(yytext); return (OBJECTID); }
<INITIAL>{DIGIT}+    { yylval.symbol = stringtable.add_string(yytext); return (INT_CONST); }

{WHITESPACE}                     ;

<INITIAL>"("         { return int('('); }
<INITIAL>")"         { return int(')'); }
<INITIAL>"*"         { return int('*'); }
<INITIAL>"+"         { return int('+'); }
<INITIAL>","         { return int(','); }
<INITIAL>"-"         { return int('-'); }
<INITIAL>"."         { return int('.'); }
<INITIAL>"/"         { return int('/'); }
<INITIAL>":"         { return int(':'); }
<INITIAL>";"         { return int(';'); }
<INITIAL>"<"         { return int('<'); }
<INITIAL>"="         { return int('='); }
<INITIAL>"@"         { return int('@'); }
<INITIAL>"{"         { return int('{'); }
<INITIAL>"}"         { return int('}'); }
<INITIAL>"~"         { return int('~'); }
<INITIAL>.           { yylval.error_msg = yytext; return (ERROR); }

	/*
	* Keywords are case-insensitive except for the values true and false,
	* which must begin with a lower-case letter.
	*/


	/*
	*  String constants (C syntax)
	*  Escape sequence \c is accepted for all characters c. Except for
	*  \n \t \b \f, the result is c.
	*
	*/


%%
