GrammarParser
=============

Parsing and optimizing a grammar with flex and bison.

To build and run thoses files with the file parse.txt, use the following command (tested on linux) :

bison -d -t desembigu.y && flex desembigu.l && g++ desembigu.tab.c lex.yy.c -lfl && ./a.out parse.txt

You can find tests in the file Tests with sources, where most of the work has been done (to develop the algorithm and test it).

What works : tested with Elementary OS (Ubuntu)
- reading a file
- parsing it thanks to flex and bison
- add elements to a data structure in C++
- use this structure in order to create a factorisation on the left side
- use this structure to delete DLR and ILR

Extra things to be done :
- Parse more characters as words (current regex recognizing a character is [a-zA-Z0-9]+)

References :
http://research.microsoft.com/pubs/68869/naacl2k-proc-rev.pdf
http://www.linguist.jussieu.fr/~amsili/Ens06/poly-li324-1.pdf (p2)
http://www.cs.bgu.ac.il/~comp101/wiki.files/tirgul8.pdf (p3-4)
Those references where helpful to read solved examples, as well as detailed algorithms.
