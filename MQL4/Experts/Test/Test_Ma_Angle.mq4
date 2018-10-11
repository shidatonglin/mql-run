//+------------------------------------------------------------------+
//|                                                Test_Ma_Angle.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

const string angleIndicator = "LSMA_Angle";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   printAngleStatus();
   PrintValue();
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

int getAngleStatus(int shift){
   double up = iCustom(Symbol(),0,angleIndicator,25,15.0,4,0,0,shift);
   double down = iCustom(Symbol(),0,angleIndicator,25,15.0,4,0,1,shift);
   double zero = iCustom(Symbol(),0,angleIndicator,25,15.0,4,0,2,shift);
   if(up != 0) return 1;
   if(down != 0) return -1;
   if(zero != 0) return 0;
   return 2;
}

void printAngleStatus(){
   string up="",down="",zero="";
   int value;
   for(int i=0; i< 100;i++){
      value = getAngleStatus(i);
      if(value == 1) up += ", " + (string )i;
      if(value == -1) down += ", " + (string )i;
      if(value == 0) zero += ", " + (string )i;
   }
   Print("up->", up);
   Print("down->", down);
   Print("zero->", zero);

}

void PrintValue(){
   string str = "";
   for(int i=0; i< 10; i++){
      double up = iCustom(Symbol(),0,angleIndicator,25,15.0,4,0,0,i);
      double down = iCustom(Symbol(),0,angleIndicator,25,15.0,4,0,1,i);
      double zero = iCustom(Symbol(),0,angleIndicator,25,15.0,4,0,2,i);
      Print("->",(string)i ," up-->",up," down-->",down," zero-->",zero);
      
   }
}