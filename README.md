GrammarParser
=============
References :
Parsing and optimizing a grammar with flex and bison.

To build and run thoses files with the file parse.txt, use the following command (tested on linux) :

bison -d -t desembigu.y && flex desembigu.l && g++ desembigu.tab.c lex.yy.c -lfl && ./a.out parse.txt

You can find tests in the file Tests with sources, where most of the work has been done (to develop the algorithm and test it).

Extra things to be done :
- Parse more characters as words

http://research.microsoft.com/pubs/68869/naacl2k-proc-rev.pdf
