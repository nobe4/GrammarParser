%{
    #include <cstdio>
    #include <iostream>
    #include <string>
    #include <vector>
    #include <algorithm>
    #include <fstream>
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

    // create a string from the vector of rule
    string toString(vector< string > &rules);

    // remove a Direct Left Recursion on the rules
    // return true if the operation was sucessfull (there was a DLR)
    // return false otherwise
    bool removeDLR(vector< pair< string,vector< string > > > &rules, string symbol);

    // remove Indirect Left Recursions on the rules
    // return true if the operation was sucessfull (there was ILR(s))
    // return false otherwise
    bool removeILR(vector< pair< string,vector< string > > > &rules);

    // make a factorization over the rules
    void factorize(vector< pair< string,vector< string > > > &rules);

    // make a factorisation for the nonTerm and the symbol specified
    void facto1(vector< pair< string,vector< string > > > &rules, string nonTerm, string symbol);

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

// a rule is a non terminal symbol a whitespace and a set of symbols or epsilon
rule : 
        symbol WHITESPACE symbols {
            // cout << "cFS " << cFS << " => ";
            cFS = string($1);
            // cout << cFS << endl;
            // $$ = $1;
            // cout << "rule symbole ws : " <<  $$ << " -> " << $3 << endl;
        }
    |   symbol WHITESPACE{
            cFS = string($1);
            cSS.insert(cSS.begin(),string("ε"));
        }
    |   symbol{
            cFS = string($1);
            cSS.insert(cSS.begin(),string("ε"));
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

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));
    
    print(rules);

    // removeILR(rules);

    facto1(rules,string("A"),string("c"));

    print(rules);

    // // display the parsed grammar to the file parsed.txt
    // ofstream output("parsed.txt");
    // if(output.is_open()){
    //     for(int i = 0; i < rules.size(); ++i){
    //         output << rules.at(i).first << " ";
    //         for(int j = 0; j < rules.at(i).second.size(); j ++){
    //             output << rules.at(i).second.at(j) << " ";
    //         }
    //         output << endl;
    //     }
    // }
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
    cout << "\n\n\n";
}

string toString(vector< string > &rules){
    string r = "";
    for(int i = 0; i < rules.size(); ++i){
        r += rules.at(i) + " ";
    }
    return r;
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
    // we add the empty state for the new symbol
    vector<string> epsilonTmp;
    epsilonTmp.push_back("ε");
    rules.push_back(make_pair(newSymbol,epsilonTmp));
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
    return true;
}

bool removeILR(vector< pair< string,vector< string > > > &rules){

    // detecting all non terminals and add it in the nonTerm Vector
    vector<string> nonTerm;
    for(int i = 0; i < rules.size(); ++i){
        if(find(nonTerm.begin(),nonTerm.end(),rules.at(i).first) == nonTerm.end()){
            nonTerm.push_back(rules.at(i).first);
        }
    }

    // cout << "non terminals : " << toString(nonTerm) << endl;

    // follow the algorithm : for each non terminal symbol
    for (int i = 0; i < nonTerm.size(); ++i){
        // cout << "i : " << i << " -> " << nonTerm.at(i) << endl;
        for (int j = 0; j < i; ++j){
            // cout << "j : " << j << " -> " << nonTerm.at(j) << endl;
            // we search for a rule like the following : Ai -> Aj b
            for(int k = 0; k < rules.size(); ++k){
                // cout << "k : " << k << " : " << rules.at(k).first << " -> " << toString(rules.at(k).second) << endl;
                if(rules.at(k).first == nonTerm.at(i) && rules.at(k).second.at(0) == nonTerm.at(j)){
                    // cout << "working on this rule" << endl;
                    // we search for production : Aj -> x
                    for(int l = 0; l < rules.size(); ++l){
                        // cout << "l : " << l << " : " << rules.at(l).first << " ?= " << nonTerm.at(j) << endl;
                        if(rules.at(l).first == nonTerm.at(j)){
                            // cout << "Ai : " << rules.at(l).first << " -> " << toString(rules.at(l).second) << endl;
                            // cout << "k : " << k  << " Aj : " << rules.at(k).first << " -> " << toString(rules.at(k).second) << endl;

                            // construct the new rule : Ai -> x b
                            vector<string> newRuleFromAj = rules.at(k).second;
                            vector<string> newRuleFromAi = rules.at(l).second;

                            // cout << "newRuleFromAi: " << toString(newRuleFromAi) << endl;
                            // cout << "newRuleFromAj before removing : " << toString(newRuleFromAj) << endl;

                            // we erase the Aj from the new RuleFromAi : 
                            newRuleFromAj.erase(newRuleFromAj.begin());
                            // cout << "newRuleFromAj after removing : " << toString(newRuleFromAj) << endl;
                            // we concatenate the both :
                            newRuleFromAi.insert(newRuleFromAi.end(),newRuleFromAj.begin(), newRuleFromAj.end());
                            
                            // we add the new rule to the existing rules
                            // cout << "newRuleFromAj after concatenate : " << toString(newRuleFromAi) << endl;
                            // cout << "before adding rule" << endl;
                            // print(rules);
                            rules.push_back(make_pair(nonTerm.at(i),newRuleFromAi));
                            // cout << "after adding rule" << endl;
                            // print(rules);
                        }
                    }
                    // we remove the current rule to avoid redundance
                    rules.erase(rules.begin() + k);
                }
            }
        }
        // we remove the DLR for the symbole
        removeDLR(rules,nonTerm.at(i));
    }
    return true; // execution successed
}

void factorize(vector< pair< string,vector< string > > > &rules){}

void facto1(vector< pair< string,vector< string > > > &rules, string nonTerm, string symbol){
    vector< pair< string,vector< string > > >::iterator it;
    for (it = rules.begin(); it != rules.end(); ++it){
        // if we match the good rule
        if(it->first == nonTerm && it->second.at(0) == symbol){
            vector< string > newSecond = it->second;
            newSecond.erase(newSecond.begin()); //  we remove the first symbol
            rules.erase(it); // we remove the rule
            --it;       // we decremente the iterator to avoid missing a element
            rules.push_back(make_pair(nonTerm + ",",newSecond)); // we add the new rule
        }
    }
    //we create and add the rule with the newNonTerm in the productionn
    vector< string > newSecond;
    newSecond.push_back(symbol);
    newSecond.push_back(nonTerm + ",");
    rules.push_back(make_pair(nonTerm,newSecond));
}