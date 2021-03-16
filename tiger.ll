/***
	Copy your own tiger.ll here, and make the following changes:
	1. replace the line 
			#include "tokens.h"
	   by 
	   		#include "tiger.tab.hh"

***/





/* Start of 1st section
	Specify flex option
	code block that gets copied to lex.yy.cc
	includes, and header files
	define global variables and REs
	prototypes of functions to be used
*/

/*Flex options here*/
%option noyywrap
%option never-interactive
%option nounistd
%option c++

/*includes and header*/
%{
#include <iostream>
#include <string>
#include <sstream>
#include "tiger.tab.hh"
#include "ErrorMsg.h"

using std::string;
using std::stringstream;

/* define global varibles*/
ErrorMsg			errormsg;	//error handler

int		comment_depth = 0;	// depth of the nested comment
string	value = "";			// the value of current string

int			beginLine=-1;	//beginning line no of a string or comment
int			beginCol=-1;	//beginning column no of a string or comment

int		linenum = 1;		//beginning line no of the current matched token
int		colnum = 1;			//beginning column no of the current matched token
int		tokenCol = 1;		//column no after the current matched token
int x = 0;
int y = 0;
string illegalTokenCode = "";

//the following defines actions that will be taken automatically after
//each token match. It is used to update colnum and tokenCol automatically.
#define YY_USER_ACTION {colnum = tokenCol; tokenCol=colnum+yyleng;}

int string2int(string);			//convert a string to integer value
void newline(void);				//trace the line #
void error(int, int, string);	//output the error message referring to the current token
%}

/* Defines of REs */
ALPHA		[A-Za-z]
DIGIT		[0-9]
INT			[0-9]+
IDENTIFIER	{ALPHA}(({ALPHA}|{DIGIT}|"_")*)

/* Start conditions for comments and strings
	used to decide if certain rules are active
	used to construct mini scanners
	can be exclusive uses %s
	inclusive uses %x
*/
%x COMMENT_ECOND
%s COMMENT_ICOND
%x STRING_ECOND
%s STRING_ICOND

/* Start 2nd Section
	Rule Section
	each rule is in the following format
	a_RE {action in c++ code}
*/
%%

"while"			{ return WHILE; }
"for"			{ return FOR; }
"to"			{ return TO; }
"break"			{ return BREAK; }
"let"			{ return LET; }
"in"			{ return IN; }
"end"			{ return END; }
"function"		{ return FUNCTION; }
"var"			{ return VAR; }
"type"			{ return TYPE; }
"array"			{ return ARRAY; }
"if"			{ return IF; }
"then"			{ return THEN; }
"else"			{ return ELSE; }
"do"			{ return DO; }
"of"			{ return OF; }
"nil"			{ return NIL; }

","				{ return COMMA; }
":"				{ return COLON; }
";"				{ return SEMICOLON; }
"("				{ return LPAREN; }
")"				{ return RPAREN; }
"["				{ return LBRACK; }
"]"				{ return RBRACK; }
"{"				{ return LBRACE; }
"}"				{ return RBRACE; }
"."				{ return DOT; }
"+"				{ return PLUS; }
"-"				{ return MINUS; }
"*"				{ return TIMES; }
"/"				{ return DIVIDE; }
"="				{ return EQ; }
"<>"			{ return NEQ; }
"<"				{ return LT; }
"<="			{ return LE; }
">"				{ return GT; }
">="			{ return GE; }
"&"				{ return AND; }
"|"				{ return OR; }
":="			{ return ASSIGN; }


"/*"			{	/* entering comment */
					comment_depth ++;
					x = linenum;
					y = colnum;
					BEGIN(COMMENT_ECOND);
}

<COMMENT_ECOND>"/*"	{	/* nested comment */
					comment_depth ++;
}

<COMMENT_ECOND>[^*/\n]*	{	/*eat anything that's not a '*' */ }

<COMMENT_ECOND>"/"+[^/*\n]*  {	/*eat anything that's not a '*' */ }

<COMMENT_ECOND>"*"+[^*/\n]*	{	/* eat up '*'s not followed by '/'s */	}


<COMMENT_ECOND>\n		{	/* trace line # and reset column related variable */
					newline();
}

<COMMENT_ECOND>"*"+"/"	{	/* close of a comment */
						comment_depth --;
						if ( comment_depth == 0 )
						{
							BEGIN(INITIAL);
						}
					}
<COMMENT_ECOND><<EOF>>	{	/* unclosed comments */
						error(x, y, "unclosed comments");
						yyterminate();
}


"\""			{   /*Begin a string thread*/
					value = "";
					beginLine = linenum;
					beginCol = colnum;
					BEGIN(STRING_ECOND);
}

<STRING_ECOND>"\""		{   /*Exit a string*/
					yylval.sval = new string(value);
					BEGIN(INITIAL);
					return STRING;
}

<STRING_ECOND><<EOF>>	{   /*finding an unclosed string */
					error(linenum, colnum, "unclosed string");
					yyterminate();
}

<STRING_ECOND>[^"\n\t\\"]*	{ /*Appending strings that do not contain newline and tab*/  value += YYText();  }

<STRING_ECOND>\n			{ /*ignore newline and append, then reset the string*/
					error(beginLine, beginCol, "unclosed string");
					yylval.sval = new string(value);
					newline();
					BEGIN(INITIAL);
					return STRING;
				}
<STRING_ECOND>\\n {  /*appending a newline to a string*/ value += "\n";}
<STRING_ECOND>\\t { /*appending a tab to a string*/ value += "\t";}
<STRING_ECOND>\\\\ {/*appending a double slash to a string*/ value +="\\";}
<STRING_ECOND>\\\" {/*appending a double quote into a string*/ value += "\"";}
<STRING_ECOND>\\[^"nt\\] {/*finding an illegal token*/
					illegalTokenCode = YYText();
					error(linenum, colnum, illegalTokenCode+" illegal token");
				}


" "				{}
\t				{}
\b				{}
\n				{newline(); }


{IDENTIFIER} 	{ value = YYText(); yylval.sval = new string(value); return ID; }
{INT}		 	{ yylval.ival = string2int(YYText()); return INT; }

<<EOF>>			{	yyterminate(); }

.				{	error(linenum, colnum, string(YYText()) + " illegal token");}


%%

int string2int( string val )
{
	stringstream	ss(val);
	int				retval;

	ss >> retval;

	return retval;
}

void newline()
{
	linenum ++;
	colnum = 1;
	tokenCol = 1;
}

void error(int line, int col, string msg)
{
	errormsg.error(line, col, msg);
}

	prototypes of functions to be used
*/

/*Flex options here*/
%option noyywrap
%option never-interactive
%option nounistd
%option c++

/*includes and header*/
%{
#include <iostream>
#include <string>
#include <sstream>
#include "tokens.h"
#include "ErrorMsg.h"

using std::string;
using std::stringstream;

/* define global varibles*/
ErrorMsg			errormsg;	//error handler

int		comment_depth = 0;	// depth of the nested comment
string	value = "";			// the value of current string

int			beginLine=-1;	//beginning line no of a string or comment
int			beginCol=-1;	//beginning column no of a string or comment

int		linenum = 1;		//beginning line no of the current matched token
int		colnum = 1;			//beginning column no of the current matched token
int		tokenCol = 1;		//column no after the current matched token
int x = 0;
int y = 0;

//the following defines actions that will be taken automatically after
//each token match. It is used to update colnum and tokenCol automatically.
#define YY_USER_ACTION {colnum = tokenCol; tokenCol=colnum+yyleng;}

int string2int(string);			//convert a string to integer value
void newline(void);				//trace the line #
void error(int, int, string);	//output the error message referring to the current token
%}

/* Defines of REs */
ALPHA		[A-Za-z]
DIGIT		[0-9]
INT			[0-9]+
IDENTIFIER	{ALPHA}(({ALPHA}|{DIGIT}|"_")*)

/* Start conditions for comments and strings
	used to decide if certain rules are active
	used to construct mini scanners
	can be exclusive uses %s
	inclusive uses %x
*/
%x COMMENT_ECOND
%s COMMENT_ICOND
%x STRING_ECOND
%s STRING_ICOND

/* Start 2nd Section
	Rule Section
	each rule is in the following format
	a_RE {action in c++ code}
*/
%%
/* Reserved Words*/
"while"			{ return WHILE; }
"for"			{ return FOR; }
"to"			{ return TO; }
"break"			{ return BREAK; }
"let"			{ return LET; }
"in"			{ return IN; }
"end"			{ return END; }
"function"		{ return FUNCTION; }
"var"			{ return VAR; }
"type"			{ return TYPE; }
"array"			{ return ARRAY; }
"if"			{ return IF; }
"then"			{ return THEN; }
"else"			{ return ELSE; }
"do"			{ return DO; }
"of"			{ return OF; }
"nil"			{ return NIL; }
/* punctuations symbols */
","				{ return COMMA; }
":"				{ return COLON; }
";"				{ return SEMICOLON; }
"("				{ return LPAREN; }
")"				{ return RPAREN; }
"["				{ return LBRACK; }
"]"				{ return RBRACK; }
"{"				{ return LBRACE; }
"}"				{ return RBRACE; }
"."				{ return DOT; }
"+"				{ return PLUS; }
"-"				{ return MINUS; }
"*"				{ return TIMES; }
"/"				{ return DIVIDE; }
"="				{ return EQ; }
"<>"			{ return NEQ; }
"<"				{ return LT; }
"<="			{ return LE; }
">"				{ return GT; }
">="			{ return GE; }
"&"				{ return AND; }
"|"				{ return OR; }
":="			{ return ASSIGN; }

/* Comment rules
*/
"/*"			{	/* entering comment */
					comment_depth ++;
					x = linenum;
					y = colnum;
					BEGIN(COMMENT_ECOND);
}

<<COMMENT_ECOND>"/*"	{	/* nested comment */
					comment_depth ++;
}

<COMMENT_ECOND>[^*/\n]*	{	/*eat anything that's not a '*' */ }

<COMMENT_ECOND>"/"+[^/*\n]*  {	/*eat anything that's not a '*' */ }

<COMMENT_ECOND>"*"+[^*/\n]*	{	/* eat up '*'s not followed by '/'s */	}

/*can also use  to reset
linenum++
colnum = tokenCol = 1;
*/
<COMMENT_ECOND>\n		{	/* trace line # and reset column related variable */
					newline();
}

<COMMENT_ECOND>"*"+"/"	{	/* close of a comment */
						comment_depth --;
						if ( comment_depth == 0 )
						{
							BEGIN(INITIAL);
						}
					}
<COMMENT_ECOND><<EOF>>	{	/* unclosed comments */
						error(x, y, "unclosed comments");
						yyterminate();
}

/* String rules
REs to recongize \t \n \\ \"
*/
"\""			{   /*Begin a string thread*/
					value = "";
					beginLine = linenum;
					beginCol = colnum;
					BEGIN(STRING_ECOND);
}

<STRING_ECOND>"\""		{   /*Exit a string*/
					yylval.sval = new string(value);
					BEGIN(INITIAL);
					return STRING;
}

<STRING_ECOND><<EOF>>	{   /*finding an unclosed string */
					error(linenum, colnum, "unclosed string");
					yyterminate();
}

<STRING_ECOND>[^"\n\t\\"]*	{ /*Appending strings that do not contain newline and tab*/  value += YYText();  }

<STRING_ECOND>\n			{ /*ignore newline and append, then reset the string*/
					error(beginLine, beginCol, "unclosed string");
					yylval.sval = new string(value);
					newline();
					BEGIN(INITIAL);
					return STRING;
				}
<STRING_ECOND>\\n {  /*appending a newline to a string*/ value += "\n";}
<STRING_ECOND>\\t { /*appending a tab to a string*/ value += "\t";}
<STRING_ECOND>\\\\ {/*appending a double slash to a string*/ value +="\\";}
<STRING_ECOND>\\\" {/*appending a double quote into a string*/ value += "\"";}
<STRING_ECOND>\\[^"nt\\] {/*finding an illegal token*/
					illegalTokenCode = YYText();
					error(linenum, colnum, illegalTokenCode+" illegal token");
				}

/* Indentifiers, white space characters etc.*/
" "				{}
\t				{}
\b				{}
\n				{newline(); }

"<" 			{ return LT; }
">" 			{ return GT; }
{IDENTIFIER} 	{ value = YYText(); yylval.sval = new string(value); return ID; }
{INT}		 	{ yylval.ival = string2int(YYText()); return INT; }

<<EOF>>			{	yyterminate(); }

.				{	error(linenum, colnum, string(YYText()) + " illegal token");}

/* Start of 3rd Section
functions that will be used
all content in this section will be copied without any change
to the output file of flex (lex.yy.cc)
main function
*/
%%

int string2int( string val )
{
	stringstream	ss(val);
	int				retval;

	ss >> retval;

	return retval;
}

void newline()
{
	linenum ++;
	colnum = 1;
	tokenCol = 1;
}

void error(int line, int col, string msg)
{
	errormsg.error(line, col, msg);
}
/* main example
int main(int argc, char **argv) {
	std::ifstream	ifs;
	int				tok;
	yyFlexLexer		lexer;

	if (argc!=2)
	{
		std::cerr << "usage: " << argv[0] << " filename" << endl;
		return 1;
	}
	ifs.open( argv[1] );
	if( !ifs )
	{
		std::cerr << "Input file cannot be opened.\n";
        return 0;
	}
	std::cout << "Lexcial Analysis of the file " << argv[1] << endl;

	lexer.switch_streams(&ifs, NULL);

	while (	tok = lexer.yylex() )
	{
		switch(tok)
		{
		case INT:
			std::cout << "INT at [ " << line << ":" << begin_colno << "]: "<< lexer.YYText() << endl;;
			break;
		case IDENTIFIER:
			std::cout << "IDENTIFIER at [ " << line << ":" << begin_colno << "]: "<< lexer.YYText() << endl;;
			break;
		default:
			std::cout << "Legal Token at [ " << line << ":" << begin_colno << "]: "<< lexer.YYText() << endl;;
		}
	}
	return 0;
}
*/
© 2021 GitHub, Inc.