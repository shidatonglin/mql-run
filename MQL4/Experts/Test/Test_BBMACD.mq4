//+------------------------------------------------------------------+
//|                                                  Test_BBMACD.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <CBBMACD.mqh>
CBbMacd *    m_bbmacd;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int shift = 1;
   m_bbmacd = new CBbMacd(NULL, 12, 26, 10, 1, 0);
   string rs = "", ups="";
   for(int i=0;i<100;i++){
      if(IsBbMacdDown(i)){
         //Print(i);
         rs += " , " + i;
      }
      if(IsBbMacdUp(i)){
         ups += " , " + i;
      }
   }
   //Print(rs);
   //Print(ups);
   Print("start");
   test1(shift);
   //testGeniess(shift);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete m_bbmacd;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
void test1(int shift){
   
   m_bbmacd.Refresh(shift);
   Print("is up-->",m_bbmacd.isUp(shift));
   Print("MainValue-->",m_bbmacd.MainValue(shift));
   Print("GetBreakLowerBandIndex-->",m_bbmacd.GetBreakLowerBandIndex(shift));
   Print("GetBreakUpperBandIndex-->",m_bbmacd.GetBreakUpperBandIndex(shift));
   Print(DOWN==m_bbmacd.Trend(shift));
}

bool IsBbMacdDown(int shift){
    m_bbmacd.Refresh(shift);
    if(!m_bbmacd.isUp(shift) && m_bbmacd.Trend(shift) == DOWN){
        return true;
    }
    return false;
}

bool IsBbMacdUp(int shift){
    m_bbmacd.Refresh(shift);
    if(m_bbmacd.isUp(shift) && m_bbmacd.Trend(shift) == UP){
        return true;
    }
    return false;
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
   Print(up);
   Print(down);
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