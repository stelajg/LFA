%{
    #include <stdio.h>
    #include<iostream>
    #include <string>
    extern "C" int yylex();
    using namespace std; 
    string alphabet;
    bool GR = false;
    bool GIC = false;
    bool GDC = false;
    bool GFR = false;
    bool Automate = false;

%}

%s AL
%s START_GRAMMAR
%s GRAMMAR_TYPE
%s START_AUTOMATON
numele [a-z]+[0-9]*
alphabet [a-z]+
nonterminals [A-Z][0-9]*
nonterminals_trans {nonterminals}" ->"
gr {alphabet}&?{nonterminals}?
gic {alphabet}?&?{nonterminals}&{alphabet}
gdc {alphabet}?&?{nonterminals}+{nonterminals}+&?{alphabet}?
states q[0-9]*

%%
{numele}/" ::= Grammar" {printf("Numele gramaticii: %s\n", yytext);BEGIN(INITIAL);}
{numele}/" ::= PushDownAutomata" {printf("Numele automatului: %s\n", yytext);
                                    Automate = true;}
<INITIAL>"alphabet :: {" {printf("am ajuns la inceput %s\n", yytext);
                                BEGIN(AL);
                            }
<AL>{alphabet} {printf("am ajuns la alphabet = %s\n", yytext);
                alphabet.push_back(yytext[0]);
                BEGIN(AL);};
<AL>" }" {printf("am ajuns la urma %s\n", yytext);
                    if(Automate == false){
                        BEGIN(START_GRAMMAR);}
                    else{
                        BEGIN(START_AUTOMATON);}}
<START_GRAMMAR>{nonterminals_trans} {printf("am ajuns la start %s\n", yytext);
            BEGIN(GRAMMAR_TYPE);}
<START_GRAMMAR>{gdc}" ->" {printf("am ajuns la gfr+++ %s\n", yytext);
                    BEGIN(GRAMMAR_TYPE);}
<GRAMMAR_TYPE>{gr} {printf("am ajuns la gr %s\n", yytext);}
<GRAMMAR_TYPE>{gic} {printf("am ajuns la gic %s\n", yytext);}
<GRAMMAR_TYPE>{gdc} {printf("am ajuns la gdc %s\n", yytext);}
<GRAMMAR_TYPE>";" {printf("am ajuns la final de linie %s\n", yytext);
                BEGIN(START_GRAMMAR);}         
<START_GRAMMAR>";;" {cout << "Alfabetul gramaticii: {" << alphabet <<" }" << endl;
        alphabet.clear();}
.|\n ;


%%
int main()
{
    yylex();
    //cout << "alphabet" << alphabet<<endl;
    printf("finis");
}