//+------------------------------------------------------------------+
//|                                              Test_ASCTrend1i.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#define IND_ASCTREND  "ASCTrend1i"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   PrintSignal();
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
   
  }
//+------------------------------------------------------------------+

double getASCTrendValue(int shift){
   double dAscTrend=iCustom(Symbol(),0,IND_ASCTREND,6,0,2,shift);
   return dAscTrend;
}

void PrintSignal(){
   int total = Bars, current = 0, previous = 0;
   string up = "", down = "";
   for(int i=0;i<total;i++){
      current =  (int)getASCTrendValue(i);
      previous =  (int)getASCTrendValue(i+1);
      if(current == 1 && previous ==-1){
         up += ", " + (string)i;
      }
      if(current == -1 && previous == 1){
         down += ", " + (string)i;
      }
   }
   Print("up -> ", up);
   Print("down -> ", down);
}