//+------------------------------------------------------------------+
//|                                                   TestMargin.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
string pair[28];
int OnInit()
  {
//---
   Assign28SymbolToList(pair);
   Print("start");
   double lots = 0.01;
   for(int i=0; i < ArraySize(pair); i++){
      Print(pair[i]," -> ", MarketInfo(pair[i],MODE_BID) , " -> ",lots, " -> ", MarginCheck(pair[i],lots));
   }
   
   //Print(MarginCheck("GBPUSD",0.01));
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

double MarginCheck(const string symbol, const double lot_size)
  {
    double availablemoney = AccountEquity();
    double marginForOneLot = MarketInfo ( symbol, MODE_MARGINREQUIRED );
    //if(availablemoney < marginForOneLot * lot_size) return false;
    //return true;
    return marginForOneLot * lot_size;
  } 
  
  
  void Assign28SymbolToList(string &array[])
  {
//EURUSD
//GBPUSD
//AUDUSD
//NZDUSD
//USDCAD
//USDJPY
//USDCHF
   array[0]="EURUSD";
   array[1]="GBPUSD";
   array[2]="AUDUSD";
   array[3]="NZDUSD";
   array[4]="USDCAD";
   array[5]="USDJPY";
   array[6]="USDCHF";
//EURGBP
//EURAUD
//EURNZD
//EURCAD
//EURJPY
//EURCHF
   array[7]="EURGBP";
   array[8]="EURAUD";
   array[9]="EURNZD";
   array[10]="EURCAD";
   array[11]="EURJPY";
   array[12]="EURCHF";
//GBPAUD
//GBPNZD
//GBPCAD
//GBPJPY
//GBPCHF
   array[13]="GBPAUD";
   array[14]="GBPNZD";
   array[15]="GBPCAD";
   array[16]="GBPJPY";
   array[17]="GBPCHF";

//AUDNZD
//AUDCAD
//AUDJPY
//AUDCHF
   array[18]="AUDNZD";
   array[19]="AUDCAD";
   array[20]="AUDJPY";
   array[21]="AUDCHF";
//NZDCAD
//NZDJPY
//NZDCHF
   array[22]="NZDCAD";
   array[23]="NZDJPY";
   array[24]="NZDCHF";
//CHFJPY
//CADCHF
//CADJPY
   array[25]="CHFJPY";
   array[26]="CADCHF";
   array[27]="CADJPY";
  }