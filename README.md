GrammarParser
=============

Parsing and optimizing a grammar with flex and bison

to build and run thoses files on the file parse.txt use this command (tested on linux) :

bison -d -t desembigu.y && flex desembigu.l && g++ desembigu.tab.c lex.yy.c -lfl && ./a.out parse.txt

