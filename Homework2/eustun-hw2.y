%{

#include <stdio.h>
void yyerror (const char * msg) /* called by yyparse on error*/ {
    return ;
}

%}

%token tMAIL tENDMAIL tSCHEDULE tENDSCHEDULE tSEND tSET tTO tFROM tAT tCOMMA tCOLON tLPR tRPR tLBR tRBR tIDENT tSTRING tDATE tTIME tADDRESS tSLC tOMLC tCMLC tNEWLINE

%%

betterStart: 
           | start betterStart
;

start: mail
     | set
;

mail: mailStart statementList tENDMAIL 
;

mailStart: tMAIL tFROM tADDRESS tCOLON
;

statementList: 
             | set statementList
             | schedule statementList
             | send statementList
;

schedule: scheduleStart scheduleEnd tENDSCHEDULE
;

scheduleEnd: send
           | send scheduleEnd
;        

scheduleStart: tSCHEDULE tAT tLBR tDATE tCOMMA tTIME tRBR tCOLON 
;


send: tSEND tLBR tIDENT tRBR tTO recipientListInBrackets
    | tSEND tLBR tSTRING tRBR tTO recipientListInBrackets
;

set: tSET tIDENT tLPR tSTRING tRPR
;



recipientListInBrackets: tLBR recipientList tRBR
;

recipientList: recipientObject 
            | recipientObject tCOMMA recipientList  
;


recipientObject: tLPR tADDRESS tRPR
               | tLPR tIDENT tCOMMA tADDRESS tRPR
               | tLPR tSTRING tCOMMA tADDRESS tRPR
;



%%

int main(){

    if (yyparse()) { // parse error
        printf("ERROR\n");
        return 1;
    }

    else { // successful parsing
        printf("OK\n");
        return 0;
    }

}