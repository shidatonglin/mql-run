//+------------------------------------------------------------------+
//|                                                      PowerSM.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include<PowerSM.mqh>


PowerSM experts[];
//string pairs[] = {"EURUSD","GBPUSD","USDJPY","USDCAD","AUDUSD"};
string pairs[] = {"EURUSD"};
int total_pairs;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   string m_comments = TimeCurrent();
   Print("----",m_comments);
//---
   total_pairs = ArraySize(pairs);
   ArrayResize(experts, total_pairs);
    
   for(int i=0; i< total_pairs; i++){
      experts[i].init(pairs[i], 5);
      if(!experts[i].validate_settings()){
         return(INIT_FAILED);
      }
   }
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
     for(int i=0; i<total_pairs; i++){
        experts[i].process();
     }
  }
//+------------------------------------------------------------------+
