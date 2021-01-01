%{
    #include <stdio.h>
    #include<iostream>
    #include <string>
    extern "C" int yylex();
    using namespace std; 
    string alphabet;
    string stack_aux;
    string state_aux;
    bool GR = false;
    bool GIC = false;
    bool GDC = false;
    bool GFR = false;
    int number_states = 0;
    bool exists_final_states = false;
    bool at_initial_state = false;
    bool next_part = false;

%}

%s AL
%s START_GRAMMAR
%s GRAMMAR_TYPE
%s INITIAL_AUTOMATA
%s START_AUTOMATON
%s PRINT_AUTOMATON
%s STATES_AUTOMATA
%s TRANSITION
%s AUX_TRANSITION
numele [a-z]+[0-9]*
alphabet [a-z]+
nonterminals [A-Z][0-9]*
nonterminals_trans {nonterminals}" ->"
gr {alphabet}&?{nonterminals}?
gic {alphabet}?&?{nonterminals}&{alphabet}
gdc {alphabet}?&?{nonterminals}+{nonterminals}+&?{alphabet}?
states q[0-9]*
stack_alphabet [A-Z]*[0-9]*
transition_stack {stack_alphabet}?&?{stack_alphabet}?

%%
{numele}/" ::= Grammar" {printf("Numele gramaticii: %s\n", yytext);BEGIN(INITIAL);}
{numele}/" ::= PushDownAutomata" {printf("Numele automatului: %s\n", yytext);
                                    printf("Tipul automatului: Automat cu stiva\n");
                                    BEGIN(INITIAL_AUTOMATA);}
<INITIAL>"alphabet :: {" {printf("am ajuns la inceput %s\n", yytext);
                                alphabet.push_back('{');
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
<START_GRAMMAR>";;" { cout << "Alfabetul gramaticii: {" << alphabet <<" }" << endl;
                     printf("\n");
                     alphabet.clear();}
<INITIAL_AUTOMATA>"alphabet ::" { printf("Alfabetulde intrare : ");
                                 BEGIN(START_AUTOMATON);}
<START_AUTOMATON>"{ " { yyless(1); 
                        printf("%s", yytext); 
                        BEGIN(START_AUTOMATON);}
<START_AUTOMATON>{alphabet} {printf("%s", yytext); 
                             BEGIN(START_AUTOMATON);}
<START_AUTOMATON>"," { printf("%s ", yytext); 
                        BEGIN(START_AUTOMATON);}
<START_AUTOMATON>"}" { printf("%s", yytext); 
                        BEGIN(PRINT_AUTOMATON);}
<PRINT_AUTOMATON>";" { printf("\n"); 
                        BEGIN(INITIAL_AUTOMATA);}
<INITIAL_AUTOMATA>"states :: {" { at_initial_state = true;
                                  BEGIN(STATES_AUTOMATA);}
<STATES_AUTOMATA>{states} { number_states++;
                            BEGIN(STATES_AUTOMATA);}
<STATES_AUTOMATA>"} ;" { printf("Numarul de stari: %d\n", number_states);
                                BEGIN(INITIAL_AUTOMATA);}
<INITIAL_AUTOMATA>"initial_state ::" { BEGIN(START_AUTOMATON);}
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
<INITIAL_AUTOMATA>"stack_alphabet ::" {printf("Alfabetul stivei: ");
                                        BEGIN(START_AUTOMATON);}
<START_AUTOMATON>{stack_alphabet} {printf("%s", yytext);
                                        BEGIN(START_AUTOMATON);}
<INITIAL_AUTOMATA>{states}" -> (" {printf("Functia de tranzitie:\n");
                                    yyless(2);
                                    string aux(yytext);
                                    state_aux = aux;
                                    BEGIN(TRANSITION);}
<TRANSITION>{alphabet} { if(yytext[0] == 'e' && next_part == true){
                            REJECT;}
                         else {
                            cout << "m(" << state_aux << ", ";
                            printf("%s, ", yytext);
                            BEGIN(TRANSITION);}}
<TRANSITION>{states} { printf("%s, ", yytext); 
                       BEGIN(TRANSITION);}
<TRANSITION>{stack_alphabet} { printf("%s)", yytext);
                               BEGIN(TRANSITION);}
<TRANSITION>"/" { printf(" = ");
                  next_part = true;
                  BEGIN(TRANSITION);}
<TRANSITION>{transition_stack}|"e" {stack_aux.clear(); string aux(yytext);
                                        stack_aux = aux;
                                        BEGIN(TRANSITION);}
<TRANSITION>{states}/" ;" { printf("(%s, ", yytext);
                            cout << stack_aux << ")" << endl;
                            BEGIN(AUX_TRANSITION);}
<AUX_TRANSITION>";" { next_part = false;
                     BEGIN(TRANSITION);}
<TRANSITION>{states}" -> (" { yyless(2);
                              string aux(yytext);
                              state_aux = aux;
                              BEGIN(TRANSITION);}
.|\n ;


%%
int main()
{
    yylex();
}