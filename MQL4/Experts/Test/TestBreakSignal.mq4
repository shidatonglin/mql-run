//+------------------------------------------------------------------+
//|                                              TestBreakSignal.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <BreakSignal.mqh>
#include <BreakSignalManager.mqh>

BreakSignal signal(NULL,0);
SignalManager manager;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //TestLagu();
   //TestBreakSignal();
   //TestSignal(4);
   //TestBarSignal(81,4);
   //TestLagu();
   //TestBarSellSignal(67,4);
   
   //TestManager();
   
   //TestGenesisSignal();
   
   //TestInsertSignal();
   TestSignal();
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

void TestLagu(){
   for(int i =0 ; i< 120;i++){
      double aguSignal = iCustom(NULL, 0, "Laguerre-ACS1", 0.6, 1000,2, 0, i);
      Print((i) , "----> ",NormalizeDouble(aguSignal,2));
   }
}

void TestBreakSignal(int i=1){
   Print("GetHaOpen---->",signal.GetHaOpen(i));
   Print("GetHaClose---->",signal.GetHaClose(i));
   //GetLastBearishBar
   Print("GetLastBearishBar---->",signal.GetLastBearishBar(i));
   //GetLastBullishBar
   Print("GetLastBullishBar---->",signal.GetLastBullishBar(i));
   //GetLastBarBelowMA
   Print("GetLastBarBelowMA---->",signal.GetLastBarBelowMA(i));
   //GetLastBarUpMA
   Print("GetLastBarUpMA---->",signal.GetLastBarUpMA(i));
   //GetLastCrossBarIndex
   Print("GetLastCrossBarIndex 1---->",signal.GetLastCrossBarIndex(1,i));
   Print("GetLastCrossBarIndex -1---->",signal.GetLastCrossBarIndex(-1,i));
}

void TestSignal(int maxBarCount=3){
   
   Print("start to test");
   int result = 0;
   for(int i=0; i< 120;i++){

      result = signal.GetBuySignal(maxBarCount,i);
      //Print("result--->",result);
      if(result != 0)
         Print("Buy ",( i )," Time :",  iTime(NULL,0,i),"---->",result);

      result = signal.GetSellSignal(maxBarCount,i);
      if(result != 0)
         Print("Sell ",( i )," Time :",  iTime(NULL,0,i),"---->",result);
   }
   //TestBreakSignal(40);
   //
   //Print("GetBuySignal ",( 52 ),"---->",signal.GetBuySignal(3,52));
}

void TestBarSignal(int shift, int maxBarCount=3){
   Print("GetBuySignal ",( shift ),"---->",signal.GetBuySignal(maxBarCount,shift));
}

void TestBarSellSignal(int shift, int maxBarCount=3){
   Print("GetSellSignal ",( shift ),"---->",signal.GetSellSignal(maxBarCount,shift));
}

void TestManager(){
   manager.CheckSignal();
   manager.SendMassage("Test send functions");
}

void TestGenesisSignal(){
   //---
   //---
   int result = 0;
   string buy="",sell="";
   for(int i=0; i < 120; i++){
      result = signal.GetGenesisSignal(i,3);
      if(result > 0) buy += " , " + i;
      if(result < 0) sell += " , " + i;
      //Print(result);
      if(result !=0) Print(i,"---",signal.GetLastGenesisRangeBarIndex(i, result));
   }
   Print("buy -->", buy);
   Print("sell--->", sell);
   //Print("current-->",signal.GetLastGenesisRangeBarIndex(1, -1));
   //Print("current-->",signal.GetLastGenesisRangeBarIndex(1, 1));
   //TestGenesisvalue();
}

void TestGenesisvalue(){
   int shift = 17;
   string name = "GenesisMatrix 2.22";
   /*
   Print(iCustom(NULL,0,name,0,shift));
   Print(iCustom(NULL,0,name,1,shift));
   Print(iCustom(NULL,0,name,2,shift));
   Print(iCustom(NULL,0,name,3,shift));
   Print(iCustom(NULL,0,name,4,shift));
   Print(iCustom(NULL,0,name,5,shift));
   Print(iCustom(NULL,0,name,6,shift));
   Print(iCustom(NULL,0,name,7,shift));
   */
   int from = -1;
   string up="",down="";
   for(int i=0; i<50; i++){
      up="";down="";
      from = 1;
      shift = i;
      if(from==1){// Current is up
         up += " , " + iCustom(NULL,0,name,0,shift); 
         up += " , " + iCustom(NULL,0,name,2,shift);
         up += " , " + iCustom(NULL,0,name,4,shift);
         up += " , " + iCustom(NULL,0,name,6,shift);
         /*
         if(iCustom(NULL,0,name,0,shift)==0) return i;
         if(iCustom(NULL,0,name,2,shift)==0) return i;
         if(iCustom(NULL,0,name,4,shift)==0) return i;
         if(iCustom(NULL,0,name,6,shift)==0) return i;
         */
      }
      from = -1;
      if(from == -1){ // current is down
         down += " , " + iCustom(NULL,0,name,1,shift); 
         down += " , " + iCustom(NULL,0,name,3,shift);
         down += " , " + iCustom(NULL,0,name,5,shift);
         down += " , " + iCustom(NULL,0,name,7,shift);
         //Print(shift);
         /*
         if(iCustom(NULL,0,name,1,shift)==0) return i;
         if(iCustom(NULL,0,name,3,shift)==0) return i;
         if(iCustom(NULL,0,name,5,shift)==0) return i;
         if(iCustom(NULL,0,name,7,shift)==0) return i;
         */
      } 
      Print(i ," up -> ", up);
      Print(i ," down -> ", down);
   }
   
   testGeniess(1);
}


void testGeniess(int shift){
   string name = "GenesisMatrix 2.22";
   string up="",down="";
   for(int i=0; i< 100;i++){
      //Print(i,"--->",iCustom(NULL,0,name,i,shift));
      if(isGenesisUp(i)){
         up += " , " + i;
      }
      if(isGenesisDown(i)){
         down += " , " + i;
      }
   }
   Print("up-->",up);
   Print("down-->",down);
   //0,2,4,6
   
}

bool isGenesisUp(int shift){
   string name = "GenesisMatrix 2.22";
   double v0 = iCustom(NULL,0,name,0,shift);
   double v2 = iCustom(NULL,0,name,2,shift);
   double v4 = iCustom(NULL,0,name,4,shift);
   double v6 = iCustom(NULL,0,name,6,shift);
   if(v0>0&&v2>0&&v4>0&&v6>0){
      return true;
   }
   return false;
}

bool isGenesisDown(int shift){
   string name = "GenesisMatrix 2.22";
   double v1 = iCustom(NULL,0,name,1,shift);
   double v3 = iCustom(NULL,0,name,3,shift);
   double v5 = iCustom(NULL,0,name,5,shift);
   double v7 = iCustom(NULL,0,name,7,shift);
   if(v1>0&&v3>0&&v5>0&&v7>0){
      return true;
   }
   return false;
}

void TestInsertSignal(){
   ExpertSignal eSignal(Symbol(),Period(),Time[0],"BreakSignal","Buy");
   manager.InsertSignal(eSignal);
    
}