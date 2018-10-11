//+------------------------------------------------------------------+
//|                                                    TestRenko.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <BreakSignal.mqh>

BreakSignal signal(NULL,0);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


int OnInit()
  {
//---
   string buy="",sell="";
   int total = Bars;
   for(int i=1; i<total-10;i++){
      if(signal.GetGenesisSignal(i,3)==1) {
         buy+= " , " + (string)i;
         //_zigZagBufferBuy[i] = Low[i];
         DrawArrowUp("buy"+(string)i,Time[i],Low[i]);
      }
      if(signal.GetGenesisSignal(i,3)==-1) {
         sell+=" , " + (string)i;
         //_zigZagBufferSell[i] = High[i];
         DrawArrowDown("sell"+(string)i,Time[i],High[i]);
         //ArrowDownCreate(0,"sell"+string(i),0,Time[i],High[i]);
      }
   }
   Print("buys -> ", buy);
   Print("sells -> ", sell);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   cleanup();
  }
  
void cleanup() {
   string name_0;
   int objs_total_8 = ObjectsTotal();
   for (int li_12 = objs_total_8 - 1; li_12 >= 0; li_12--) {
      name_0 = ObjectName(li_12);
      if (StringFind(name_0, "buy") == 0) ObjectDelete(name_0);
      if (StringFind(name_0, "sell") == 0) ObjectDelete(name_0);
   }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    
  }
//+------------------------------------------------------------------+


void DrawArrowUp(string ArrowName,datetime LineTime, double LinePrice)
{
ObjectCreate(ArrowName, OBJ_ARROW_BUY, 0, LineTime, LinePrice); //draw an up arrow
ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
ObjectSet(ArrowName, OBJPROP_WIDTH, 6);
ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
ObjectSet(ArrowName, OBJPROP_COLOR,LightSeaGreen);
}

void DrawArrowDown(string ArrowName,datetime LineTime, double LinePrice)
{
ObjectCreate(ArrowName, OBJ_ARROW_SELL, 0, LineTime, LinePrice); //draw an up arrow
ObjectSet(ArrowName, OBJPROP_STYLE, STYLE_SOLID);
ObjectSet(ArrowName, OBJPROP_WIDTH, 8);
ObjectSet(ArrowName, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
ObjectSet(ArrowName, OBJPROP_COLOR,LightSeaGreen);
}


