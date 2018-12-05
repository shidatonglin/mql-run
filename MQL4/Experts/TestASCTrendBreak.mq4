//+------------------------------------------------------------------+
//|                                            TestASCTrendBreak.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <ASCTrendBreak.mqh>

ASCTrendBreak trendBreak;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   PrintBreaks();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      static datetime last_time = 0;
      if(last_time != iTime(NULL,0,0)){
         last_time = iTime(NULL,0,0);
         PrintBreaks();
         //Print("last time-->", last_time);
      }
  }
//+------------------------------------------------------------------+

void PrintBreaks(){
   string up = "", down = "";
   int trend = 0;
   for(int i=0; i< 200;i++){
      trend = trendBreak.GetSignal(i);
      if(trend == 1) up += ", " + (string)i;
      if(trend == -1) down += ", " + (string)i;
   }
   Print("up==>",up);
   Print("down==>",down);
}