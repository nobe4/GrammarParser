%{
#include <cstdio>
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#define YYSTYPE char*

#include "desembigu.tab.h"  // necessary to get the token types that we return

%}
whiteSpace      [ \t]+
eol             {whiteSpace}*\n
word            [a-zA-Z0-9]+


%%

{eol}               { return EOL; }
{whiteSpace}        { return WHITESPACE; }
{word}              {
                        yylval = strdup(yytext);
                        return STRING;
                    }
.                   ;

%%
