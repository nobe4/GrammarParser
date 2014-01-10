GrammarParser
=============

Parsing and optimizing a grammar with flex and bison.

To build and run thoses files on the file parse.txt use this command (tested on linux) :

bison -d -t desembigu.y && flex desembigu.l && g++ desembigu.tab.c lex.yy.c -lfl && ./a.out parse.txt


You can find tests in the file Tests with sources, where most of the work was done (for developping the algorithm and test it).
