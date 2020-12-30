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
    int number_states = 0;
    bool exists_final_states = false;
    bool at_initial_state = false;

%}

%s AL
%s START_GRAMMAR
%s GRAMMAR_TYPE
%s INITIAL_AUTOMATA
%s START_AUTOMATON
%s PRINT_AUTOMATON
%s STATES_AUTOMATA
numele [a-z]+[0-9]*
alphabet [a-z]+
nonterminals [A-Z][0-9]*
nonterminals_trans {nonterminals}" ->"
gr {alphabet}&?{nonterminals}?
gic {alphabet}?&?{nonterminals}&{alphabet}
gdc {alphabet}?&?{nonterminals}+{nonterminals}+&?{alphabet}?
states q[0-9]*
stack_alphabet [A-Z]*[0-9]*

%%
{numele}/" ::= Grammar" {printf("Numele gramaticii: %s\n", yytext);BEGIN(INITIAL);}
{numele}/" ::= PushDownAutomata" {printf("Numele automatului: %s\n", yytext);
                                    printf("Tipul automatului: Automat cu stiva\n");
                                    BEGIN(INITIAL_AUTOMATA);}
<INITIAL>"alphabet :: {" {printf("am ajuns la inceput %s\n", yytext);
                                BEGIN(AL);
                            }
<AL>{alphabet} {printf("am ajuns la alphabet = %s\n", yytext);
                alphabet.push_back(yytext[0]);
                BEGIN(AL);};
<AL>" }" {printf("am ajuns la urma %s\n", yytext);
            BEGIN(START_GRAMMAR);}
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
<INITIAL_AUTOMATA>"alphabet ::" {printf("am ajuns la alphabet\n");
                                BEGIN(START_AUTOMATON);}
<START_AUTOMATON>"{ " {printf("am ajuns la alphabet = %s\n", yytext);BEGIN(START_AUTOMATON);}
<START_AUTOMATON>{alphabet} {printf("am ajuns la alphabet = %s\n", yytext);BEGIN(START_AUTOMATON);}
<START_AUTOMATON>"," {printf("am ajuns la alphabet = %s\n", yytext);BEGIN(START_AUTOMATON);}
<START_AUTOMATON>"}" {printf("am ajuns la alphabet = %s\n", yytext);BEGIN(PRINT_AUTOMATON);}
<PRINT_AUTOMATON>";" {BEGIN(INITIAL_AUTOMATA);}
<INITIAL_AUTOMATA>"states :: {" {printf("am ajuns la stari = %s\n", yytext);
                                at_initial_state = true;
                                BEGIN(STATES_AUTOMATA);}
<STATES_AUTOMATA>{states} {number_states++;
                            BEGIN(STATES_AUTOMATA);}
<STATES_AUTOMATA>"} ;" {printf("am ajuns la stari = %d\n", number_states);
                                BEGIN(INITIAL_AUTOMATA);}
<INITIAL_AUTOMATA>"initial_state ::" {BEGIN(START_AUTOMATON);}
<START_AUTOMATON>{states} {
                            if(at_initial_state && exists_final_states == false){
                                printf("Starile finale: {}\n");
                                printf("Starea initiala: %s\n", yytext);
                                BEGIN(INITIAL_AUTOMATA);
                            }
                            else if(at_initial_state && exists_final_states){
                                printf("}");
                                printf("Starea initiala: %s\n", yytext);
                                BEGIN(INITIAL_AUTOMATA);
                            }
                            else{
                                printf("Starea initiala: %s\n", yytext);
                                BEGIN(START_AUTOMATON);
                            }
                        }
                                
<INITIAL_AUTOMATA>"final_states ::" {exists_final_states = true;
                                printf("Starile finale: {");
                                BEGIN(START_AUTOMATON);}
<INITIAL_AUTOMATA>"stack_alphabet ::" {printf("am ajuns la alphabet_stack: ");
                                        BEGIN(START_AUTOMATON);}
<START_AUTOMATON>{stack_alphabet} {printf("am ajuns la alphabet_stack = %s\n", yytext);
                                        BEGIN(START_AUTOMATON);}
.|\n ;


%%
int main()
{
    yylex();
    //cout << "alphabet" << alphabet<<endl;
    printf("finis");
}