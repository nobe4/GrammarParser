%{
    #include <cstdio>
    #include <iostream>
    #include <string>
    #include <vector>
    using namespace std;

    extern "C" int yylex();
    extern "C" int yyparse();
    extern "C" FILE *yyin;

    #define YYSTYPE char *
     
    void yyerror(const char *s);

    vector< pair< string,vector< string > > > rules; // vector of rules  : a string for the first symbole and a vector of strings for the second symbols
    string cFS; // current First Symbol
    vector<string> cSS; // current Second Symbol

    // display the grammar
    void print(vector< pair< string,vector< string > > > &rules);

    // remove a Direct Left Recursion on the rules
    // return true if the operation was sucessfull (there was a DLR)
    // return false otherwise
    bool removeDLR(vector< pair< string,vector< string > > > &rules, string symbol);

%}

%token STRING EOL WHITESPACE

%%

// the gramar is nothing or the axiom only or the axioms followed by rules
grammar: /* nothing */
        | axiom
        | axiom EOL rules;

// rules are a rule, and on the next lines other rules or a single rule
rules : 
        rules EOL rule {
            rules.push_back(make_pair(cFS,cSS));
            cSS.clear();
            // $$ = $1;
            // cout << "rules rule er : " <<  $$ << " . " << $3 << endl;
        }
    |   rule {
            rules.push_back(make_pair(cFS,cSS));
            cSS.clear();
            // $$ = $1;
            // cout << "rules rule : " <<  $$ << endl;
        };
    
// the axiom is a rule
axiom : 
        rule {  
                // cout << cFS << endl;
                rules.push_back(make_pair(cFS,cSS));
                cSS.clear();
                // $$ = $1;
                // cout << "axiom rule : " <<  $$ << endl;
        };

// a rule is a non terminal symbol a whitespace and a set of symbols
rule : 
        symbol WHITESPACE symbols {
            // cout << "cFS " << cFS << " => ";
            cFS = string($1);
            // cout << cFS << endl;
            // $$ = $1;
            // cout << "rule symbole ws : " <<  $$ << " -> " << $3 << endl;
        };

// symbols are a symbol a whitespace and other symbols or only a symbol
symbols :
        symbol WHITESPACE symbols {
            cSS.insert(cSS.begin(),string($1));
            // $$ = $1;
            // cout << "symbols symbol ws ws : " <<  $$ << " _ " << $3 <<endl;
        }
    |   symbol {
           cSS.insert(cSS.begin(),string($1));
            // $$ = $1;
            // cout << "symbols symbol : " <<  $1 << endl;
        };

// a symbol is a string
symbol :
        STRING {
            $$ = $1;
            // cout << "symbol string : " <<  $$ << endl;
        };

%%

main(int c, char *v[]) {
    // open a file handle to a particular file:
    FILE *myfile = fopen(v[1], "r");
    // make sure it is valid:
    if (!myfile) {
        cout << "I can't open the file!" << endl;
        return -1;
    }
    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;
    
    // extern int yydebug;
    // yydebug = 1;
    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));
    
    print(rules);

    removeDLR(rules, string("A"));
}

void yyerror(const char *s) {
    cout << "Parse error : " << s << endl;
    // might as well halt now:
    exit(-1);
}

void print(vector< pair< string,vector< string > > > &rules){
    for(int i = 0; i < rules.size(); ++i){
        cout << rules.at(i).first << " -> ";
        for(int j = 0; j < rules.at(i).second.size(); j ++){
            cout << rules.at(i).second.at(j) << " ";
        }
        cout << endl;
    }
}

bool removeDLR(vector< pair< string,vector< string > > > &rules, string symbol){
    // we assume symbol is in the grammar
    
    // if not the function will return false without doing anything

    bool DLRExist = false; // set if the grammar has DLR for the given symbol

    // detect if there is a DLR
    vector< pair< string,vector< string > > >::iterator it = rules.begin();
    while(!DLRExist && it != rules.end()){
        if(it->first == symbol){ //if the first symbol is the one searched
            if(it->second.at(0) == symbol){ // if the first element of the second symbols is the one searched
                DLRExist = true;
            }
        }
        ++it;
    }
    if(!DLRExist) return DLRExist; // no DLR was found

    //from here a DLR was found

    // creating the new state
    string newSymbol = symbol + "'";
    pair< string,vector< string > > tmpRule; // temporary rule we will use for building the others rules
    // for all stats that contains the same first : 
    for(it = rules.begin(); it != rules.end(); ++it){
        if(it->first == symbol){
            if(it->second.at(0) == symbol){ // if the first element of the second symbols is the one searched
                it->second.erase(it->second.begin()); //  we remove the first element (the symbol)
                it->first = newSymbol;
            }
            it->second.push_back(newSymbol); // we add the new symbol
        }
    }

    print(rules);
    return true;
}