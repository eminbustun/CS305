%{
#ifdef YYDEBUG
  yydebug = 1;
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "eustun-hw3.h"
void yyerror (const char *msg) /* Called by yyparse on error */ {
  return; }


EmailScheduleNode ** emailScheduleList;
int sendNotificationSize = 100;
int sendNotificationsIndex = 0;
char ** sendNotifications;

int scheduleNotificationsSize = 100;
int scheduleNotificationsIndex = 0;
int scheduleNotificationsCheck = 0;
char ** scheduleNotifications;

char * convertDate(int, int, int);
ExpressionNode * makeExpressionFromIdent(VariableNode, VariableNode);
RecipientNode * makeRecipientFromAddress(char *, char *);
int addRecipientToRecipientList(RecipientNode * recipientNode);
int recipientExist(char * address);

int addExpressionToList(ExpressionNode *);
int addExpressionToMailList(ExpressionNode *);


int globalDay;
int globalMonth;
int globalYear;
int globalHour;
int globalMinute;
char * timeOfSchedule;


int inMail = 0;
int inSchedule = 0;

int recipientSize = 100;
int recipientIndex = 0;

RecipientNode ** recipientListArray;
ExpressionNode ** expressions;

int expressionsSize = 100;
int exprIndex = 0;
int identifierExist(VariableNode);
int identifierExistMail(VariableNode);
int error = 0;
int sendNotificationsCheck = 0;
char ** errors;
int errorSize = 100;
int errorIndex = 0;

int emailScheduleSize = 100;
int emailScheduleIndex = 0;

ExpressionNode ** mailExpressions;
int mailExpressionsSize = 100;
int mailIndex = 0;

char * sender;




%}

%union {
  VariableNode variableNode;
  ExpressionNode * expressionNode;
  ScheduleNode scheduleNode;
  SenderNode senderNode;
  StringOrIdentNode stringOrIdentNode;
  RecipientNode * recipientNode;
  SendLineNode sendLineNode;
  EmailScheduleNode * emailScheduleNode;
}


%token <variableNode> tIDENT
%token <variableNode> tSTRING
%token <scheduleNode> tDATE
%token <scheduleNode> tTIME
%token <senderNode> tADDRESS
%token <sendLineNode> tSEND
%token tMAIL tENDMAIL tSCHEDULE tENDSCHEDULE tTO tFROM tSET tCOMMA tCOLON tLPR tRPR tLBR tRBR tAT
%start program

%type <recipientNode> recipient;
%type <expressionNode> setStatement 
%type <stringOrIdentNode> option
%type <emailScheduleNode> sendStatement

%%

program : statements {


}
;

statements : 
            | setStatement statements {
              
              
            }
            | mailBlock statements {

              
              
            }
;

mailBlock : beginMailblock tFROM address tCOLON statementList endMailblock {

  int i = 0;
 

  for (; i < mailIndex; i++) {
   
        mailExpressions[i]->identifier = "\0";
        mailExpressions[i]->value = "\0";

    
}
  
  
  mailIndex = 0;
  mailExpressionsSize = 100;
  
    
}
;

address: tADDRESS {

  sender = $1.value;
  

}
;
endMailblock: tENDMAIL {

  

  inMail = 0;

  

  

}
;

beginMailblock: tMAIL {
  inMail = 1;
}
;

statementList : 
                | setStatement statementList {
                    

                }
                | sendStatement statementList 
                | scheduleStatement statementList
;

sendStatements : sendStatement
                | sendStatement sendStatements 
;

sendStatement : tSEND tLBR option tRBR tTO tLBR recipientList tRBR{
  


  if (inSchedule == 1) {
    int z = 0;
    for(; z < recipientIndex; z++) {
      
      if (strcmp("NULL" ,recipientListArray[z]->senderNameOrString) == 0) {
        
        char * convertedDate = convertDate(globalDay, globalMonth, globalYear);
        EmailScheduleNode * newNode = (EmailScheduleNode *)malloc(sizeof(EmailScheduleNode));
        newNode->emailSender = sender;
        newNode->emailMessage = $3.value;
        newNode->sendTo = recipientListArray[z]->address;
        newNode->lineNum = $1.lineNum;
        newNode->day = globalDay;
        newNode->month = globalMonth;
        newNode->year = globalYear;
        newNode->hour = globalHour;
        newNode->minute = globalMinute;
        newNode->fullTime = timeOfSchedule;

        $$ = newNode;

        
        if(emailScheduleIndex < emailScheduleSize){
            emailScheduleList[emailScheduleIndex] = $$;
            emailScheduleIndex += 1;
        }
              
        else{
            emailScheduleSize = emailScheduleSize + emailScheduleSize;
            emailScheduleList = realloc(emailScheduleList, emailScheduleSize);
            emailScheduleList[emailScheduleIndex] = $$;
            emailScheduleIndex += 1;
        }


        scheduleNotificationsCheck = 1;
        
      }
    else {
      
      char * convertedDate = convertDate(globalDay, globalMonth, globalYear);

       EmailScheduleNode * newNode = (EmailScheduleNode *)malloc(sizeof(EmailScheduleNode));
        newNode->emailSender = sender;
        newNode->emailMessage = $3.value;
        newNode->sendTo = recipientListArray[z]->senderNameOrString;
        newNode->lineNum = $1.lineNum;
        newNode->day = globalDay;
        newNode->month = globalMonth;
        newNode->year = globalYear;
        newNode->hour = globalHour;
        newNode->minute = globalMinute;
        newNode->fullTime = timeOfSchedule;

        $$ = newNode;
        
        
        if(emailScheduleIndex < emailScheduleSize){
            emailScheduleList[emailScheduleIndex] = $$;
            emailScheduleIndex += 1;
        }
              
        else{
            emailScheduleSize = emailScheduleSize + emailScheduleSize;
            emailScheduleList = realloc(emailScheduleList, emailScheduleSize);
            emailScheduleList[emailScheduleIndex] = $$;
            emailScheduleIndex += 1;
        }
      
      scheduleNotificationsCheck = 1;
      
    }

    
   
    }
  
  }

  
  else if (inSchedule == 0) {
    int z = 0;
    for(; z < recipientIndex; z++) {
      
      if (strcmp("NULL" ,recipientListArray[z]->senderNameOrString) == 0) {
        sendNotificationsCheck = 1;
        
        char * src =  "E-mail sent from %s to %s: \"%s\"\n";
        char * dest = (char *)malloc(strlen(src) + strlen(sender) + strlen(recipientListArray[z]->address) + strlen($3.value));
        sprintf(dest, src, sender, recipientListArray[z]->address, $3.value);
        if(sendNotificationsIndex < sendNotificationSize){
            sendNotifications[sendNotificationsIndex] = dest;
            sendNotificationsIndex += 1;
        }
                
        else{
            sendNotificationSize = sendNotificationSize + sendNotificationSize;
            sendNotifications = realloc(sendNotifications, sendNotificationSize);
            sendNotifications[sendNotificationsIndex] = dest;
            sendNotificationsIndex += 1;
        }
      }
      else {
        sendNotificationsCheck = 1;
        char * src =  "E-mail sent from %s to %s: \"%s\"\n";
        char * dest = (char *)malloc(strlen(src) + strlen(sender) + strlen(recipientListArray[z]->senderNameOrString) + strlen($3.value));
        sprintf(dest, src, sender, recipientListArray[z]->senderNameOrString, $3.value);
        if(sendNotificationsIndex < sendNotificationSize){
            sendNotifications[sendNotificationsIndex] = dest;
            sendNotificationsIndex += 1;
        }
                
        else{
            sendNotificationSize = sendNotificationSize + sendNotificationSize;
            sendNotifications = realloc(sendNotifications, sendNotificationSize);
            sendNotifications[sendNotificationsIndex] = dest;
            sendNotificationsIndex += 1;
        }
      }
      }
  
  }
  
  int i = 0;
    for (; i < recipientIndex; i++) {
    
      recipientListArray[i]->address = NULL;
      recipientListArray[i]->senderNameOrString = NULL;
      recipientListArray[i] = NULL;
      }
  
    recipientIndex = 0;
    recipientSize = 100;

 
  
}
;

option: tSTRING{
  $$.value = $1.value;
} | tIDENT{

  int existenceForMail = identifierExistMail($1);
  int existenceForGlobal = identifierExist($1);


  if (existenceForMail < 0 ){

    if (existenceForGlobal < 0) {
      error = 1;
      char * src =  "ERROR at line %d: %s is undefined\n";
      char * dest = (char *)malloc(strlen(src) + $1.lineNum + 10);
      sprintf(dest, src, $1.lineNum, $1.value);
      if(errorIndex < errorSize){
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
              
      else{
          errorSize = errorSize + errorSize;
          errors = realloc(errors, errorSize);
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
    }

    else if (existenceForGlobal >= 0) {
      $$.value = expressions[existenceForGlobal]->value;
    }

  }
  else if (existenceForMail >= 0) {
    $$.value = mailExpressions[existenceForMail]->value;

  }
  
}
;


recipientList : recipient {
  
}
            | recipient tCOMMA recipientList 
;

recipient : tLPR tADDRESS tRPR {
              $$ = makeRecipientFromAddress($2.value, "NULL");

              int a = recipientExist($2.value);

              if (a < 0) {
                addRecipientToRecipientList($$);

              }
            }
            | tLPR tSTRING tCOMMA tADDRESS tRPR {
                
                $$ = makeRecipientFromAddress($4.value, $2.value);


                int a = recipientExist($4.value);

                if (a < 0) {
                addRecipientToRecipientList($$);
              


                }
                
               

            }
            | tLPR tIDENT tCOMMA tADDRESS tRPR  {
              
  int existenceForMail = identifierExistMail($2);

  int existenceForGlobal = identifierExist($2);

 
  
  if (existenceForMail < 0 ){

    if (existenceForGlobal < 0) {
      error = 1;
      char * src =  "ERROR at line %d: %s is undefined\n";
      char * dest = (char *)malloc(strlen(src) + $2.lineNum + 10);
      sprintf(dest, src, $2.lineNum, $2.value);
      if(errorIndex < errorSize){
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
              
      else{
          errorSize = errorSize + errorSize;
          errors = realloc(errors, errorSize);
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
    }

    else if (existenceForGlobal >= 0) {
      
      $$ = makeRecipientFromAddress($4.value, expressions[existenceForGlobal]->value);

      int a = recipientExist($4.value);
      if (a < 0) {
        addRecipientToRecipientList($$);
      }
      
    }

  }

  else if (existenceForMail >= 0) {
    
    $$ = makeRecipientFromAddress($4.value, mailExpressions[existenceForMail]->value);

    int a = recipientExist($4.value);

    if (a < 0) {
    addRecipientToRecipientList($$);

    }
  }


}
;

scheduleStatement : beginSchedule tAT tLBR dateParser tCOMMA timeParser tRBR tCOLON sendStatements endSchedule {


  
  
}
;

timeParser: tTIME {

  timeOfSchedule = $1.value;

 int hour, minute;

 if (sscanf($1.value, "%d:%d", &hour, &minute) == 2) {

  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {

    error = 1;
      char * src =  "ERROR at line %d: time object is not correct (%s)\n";
      char * dest = (char *)malloc(strlen(src) + $1.lineNum + 10);
      sprintf(dest, src, $1.lineNum, $1.value);
      if(errorIndex < errorSize){
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
              
      else{
          errorSize = errorSize + errorSize;
          errors = realloc(errors, errorSize);
          errors[errorIndex] = dest;
          errorIndex += 1;
      }

  }

  globalHour = hour;
  globalMinute = minute;

  
 }
}
;

dateParser: tDATE {

   int day, month, year;

  if (sscanf($1.value, "%d-%d-%d", &day, &month, &year) == 3 || sscanf($1.value, "%d.%d.%d", &day, &month, &year) == 3 || sscanf($1.value, "%d/%d/%d", &day, &month, &year) == 3) {


    if (day < 0 || day > 31 || month < 0 || month > 12 || year < 0) {

      error = 1;
      char * src =  "ERROR at line %d: date object is not correct (%s)\n";
      char * dest = (char *)malloc(strlen(src) + $1.lineNum + 10);
      sprintf(dest, src, $1.lineNum, $1.value);
      if(errorIndex < errorSize){
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
              
      else{
          errorSize = errorSize + errorSize;
          errors = realloc(errors, errorSize);
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
    }

    else if (year % 4 != 0 && month == 2 && day > 28) {

      error = 1;
      char * src =  "ERROR at line %d: date object is not correct (%s)\n";
      char * dest = (char *)malloc(strlen(src) + $1.lineNum + 10);
      sprintf(dest, src, $1.lineNum, $1.value);
      if(errorIndex < errorSize){
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
              
      else{
          errorSize = errorSize + errorSize;
          errors = realloc(errors, errorSize);
          errors[errorIndex] = dest;
          errorIndex += 1;
        }
    }

    else if (year % 4 == 0 && month == 2 && day > 29) {
      error = 1;
      char * src =  "ERROR at line %d: date object is not correct (%s)\n";
      char * dest = (char *)malloc(strlen(src) + $1.lineNum + 10);
      sprintf(dest, src, $1.lineNum, $1.value);
      if(errorIndex < errorSize){
          errors[errorIndex] = dest;
          errorIndex += 1;
      }
              
      else{
          errorSize = errorSize + errorSize;
          errors = realloc(errors, errorSize);
          errors[errorIndex] = dest;
          errorIndex += 1;
        }

    }
  
   
  globalDay = day;
  globalMonth = month;
  globalYear = year;


  
 }

}
;

beginSchedule: tSCHEDULE {
  inSchedule = 1;
}
;
endSchedule : tENDSCHEDULE {
  inSchedule = 0;
}
;
setStatement : tSET tIDENT tLPR tSTRING tRPR {
  
  $$ = makeExpressionFromIdent($2, $4);
  
    
  

  if (inMail == 1) {

    addExpressionToMailList($$);
  }

  else if (inMail == 0){
    
    addExpressionToList($$);
  }
 
}
;


%%

ExpressionNode * makeExpressionFromIdent(VariableNode ident, VariableNode string){
  
  int a = identifierExist(ident);
   

  int b = identifierExistMail(ident);
  
  if (a >= 0 && inMail == 0) {

    expressions[a]->value = string.value;
    expressions[a]->lineNum = string.lineNum;
    

  }

  else if (b >= 0 && inMail == 1) {

    mailExpressions[b]->value = string.value;
    mailExpressions[b]->lineNum = string.lineNum;

  }

  
  else {
  ExpressionNode * newNode = (ExpressionNode *)malloc(sizeof(ExpressionNode));  
  newNode->identifier = ident.value;
  newNode->value = string.value;
  newNode->lineNum = ident.lineNum;
  
  return newNode;

  }
  
}





RecipientNode * makeRecipientFromAddress(char * address, char * senderNameOrString){

  int a = recipientExist(address);


  if (a >= 0) {


  }
  
  else if (a < 0) {
  RecipientNode * newNode = (RecipientNode *)malloc(sizeof(RecipientNode));  
  newNode->address = address;
  newNode->senderNameOrString = senderNameOrString;
  return newNode;

  }
  
}

int recipientExist(char * address) {
  int i = 0;
  for (; i < recipientIndex;) {
    if (strcmp(address ,recipientListArray[i]->address) == 0) {
      return i;
    }
    i += 1;
  }
  return -1;
}


int identifierExist(VariableNode ident) {
  
  int i = 0;
  for (; i < exprIndex;) {
    
    if (strcmp(ident.value ,expressions[i]->identifier) == 0) {
      return i;
    }
    i += 1;
  }
  return -1;
}

int identifierExistMail(VariableNode ident) {
  int i = 0;
  for (; i < mailIndex;) {
    

    if (strcmp(ident.value ,mailExpressions[i]->identifier) == 0) {
          return i;
        }
        i += 1;
    
    
  }
  return -1;
}


int addExpressionToList(ExpressionNode * newExpr){
    /* Add expression to expressions list */
        if(exprIndex < expressionsSize){
            expressions[exprIndex] = newExpr;
            exprIndex += 1;
        }
        else{
            expressionsSize = expressionsSize + expressionsSize;
            expressions = realloc(expressions, expressionsSize);
            expressions[exprIndex] = newExpr;
            exprIndex += 1;
        }
}

int addRecipientToRecipientList(RecipientNode * recipientNode){
    /* Add expression to expressions list */
        if(recipientIndex < recipientSize){
            recipientListArray[recipientIndex] = recipientNode;
            recipientIndex += 1;
        }
        else{
            recipientSize = recipientSize + recipientSize;
            recipientListArray = realloc(recipientListArray, recipientSize);
            recipientListArray[recipientIndex] = recipientNode;
            recipientIndex += 1;
        }
}


int addExpressionToMailList(ExpressionNode * newExpr){
        if(mailIndex < mailExpressionsSize){
          
             mailExpressions[mailIndex] = newExpr;
            mailIndex += 1;
          
          
        }
        else{
          
            mailExpressionsSize = mailExpressionsSize + mailExpressionsSize;
            mailExpressions = realloc(mailExpressions, mailExpressionsSize);
            mailExpressions[mailIndex] = newExpr;
            mailIndex += 1;
        }
}

char* convertDate(int day, int month, int year) {
  char* result = malloc(20);  // Allocate enough space for the resulting string

  if (month == 1) {
    sprintf(result, "January %d, %d", day, year);
  } else if (month == 2) {
    sprintf(result, "February %d, %d", day, year);
  } else if (month == 3) {
    sprintf(result, "March %d, %d", day, year);
  } else if (month == 4) {
    sprintf(result, "April %d, %d", day, year);
  } else if (month == 5) {
    sprintf(result, "May %d, %d", day, year);
  } else if (month == 6) {
    sprintf(result, "June %d, %d", day, year);
  } else if (month == 7) {
    sprintf(result, "July %d, %d", day, year);
  } else if (month == 8) {
    sprintf(result, "August %d, %d", day, year);
  } else if (month == 9) {
    sprintf(result, "September %d, %d", day, year);
  } else if (month == 10) {
    sprintf(result, "October %d, %d", day, year);
  } else if (month == 11) {
    sprintf(result, "November %d, %d", day, year);
  } else if (month == 12) {
    sprintf(result, "December %d, %d", day, year);
  }

  return result;
}


int compareEmailDates (const void * a, const void * b){

  const EmailScheduleNode *emailA = *(const EmailScheduleNode **)a;
  const EmailScheduleNode *emailB = *(const EmailScheduleNode **)b;

  if (emailA->year != emailB->year ){
    return emailA->year - emailB->year;
  }
  if (emailA->month != emailB->month ){
    return emailA->month - emailB->month;
  }
  if (emailA->day != emailB->day ){
    return emailA->day - emailB->day;
  }
  if (emailA->hour != emailB->hour ){
    return emailA->hour - emailB->hour;
  }
  if (emailA->minute != emailB->minute ){
    return emailA->minute - emailB->minute;
  }

  return 0;
}


int main () 
{
    expressions = (ExpressionNode**)malloc(expressionsSize * sizeof(ExpressionNode*));
    errors = (char**)malloc(errorSize * sizeof(char*));
    mailExpressions = (ExpressionNode**)malloc(mailExpressionsSize * sizeof(ExpressionNode*));
    recipientListArray = (RecipientNode **)malloc(recipientSize * sizeof(RecipientNode*));
    sendNotifications = (char**)malloc(sendNotificationSize * sizeof(char*));
    scheduleNotifications = (char**)malloc(scheduleNotificationsSize * sizeof(char*));
    emailScheduleList = (EmailScheduleNode**)malloc(emailScheduleSize * sizeof(EmailScheduleNode*));

  int i = 0;
  

   if (yyparse())
   {
      printf("ERROR\n");
      return 1;
    } 
    else 
    {      
        if(error == 1) {
          int i = 0;
          for(; i < errorIndex; i++) {
            printf(errors[i]);
          }
        }

        else if (error == 0) {

          if (sendNotificationsCheck == 1){
            int k = 0;
            for (; k < sendNotificationsIndex; k++){
              printf(sendNotifications[k]);
            }
          }
          if (scheduleNotificationsCheck == 1){

            qsort(emailScheduleList, emailScheduleIndex, sizeof(EmailScheduleNode*), compareEmailDates);

              int i = 0;
             for ( ; i < emailScheduleIndex; i++) {
              char * date = convertDate (emailScheduleList[i]->day, emailScheduleList[i]->month, emailScheduleList[i]->year);
                printf("E-mail scheduled to be sent from %s on %s, %s to %s: \"%s\"\n",
               emailScheduleList[i]->emailSender, date, emailScheduleList[i]->fullTime, emailScheduleList[i]->sendTo,
               emailScheduleList[i]->emailMessage);
              }


          }

          
        }

        else {
          
        }
        return 0;
    } 
}