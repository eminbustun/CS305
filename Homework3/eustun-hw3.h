#ifndef __MS_H
#define __MS_H

typedef struct VariableNode
{
   char *value;
   int lineNum;
   int depth; // 0 or 1. If it's in mail block it is 0, if it is global variable it is 1
} VariableNode;

typedef struct ScheduleNode
{
   char *value;
   int lineNum;
} ScheduleNode;

typedef struct SenderNode
{
   char *value;
   
} SenderNode;

typedef struct StringOrIdentNode
{
   char *value;
   
} StringOrIdentNode;

typedef struct RecipientNode
{
   char * address;
   char * senderNameOrString;
   
} RecipientNode;

typedef struct SendLineNode
{
   int lineNum;
   
} SendLineNode;

typedef struct RecipientListNode
{
   
   RecipientNode * recipientNode;
   
} RecipientListNode;




typedef struct EmailScheduleNode
{
   
   char * emailSender;
   char * emailMessage;
   char * sendTo;
   char * fullTime;
   int lineNum;
   int day;
   int month;
   int year;
   int minute;
   int hour;
   
} EmailScheduleNode;



typedef struct ExpressionNode
{
    char *identifier;
    char *value;
    int lineNum;
    int depth; // 0 or 1. If it's in mail block it is 0, if it is global variable it is 1
    
} ExpressionNode;

#endif