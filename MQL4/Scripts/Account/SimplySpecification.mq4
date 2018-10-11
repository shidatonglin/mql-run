//+------------------------------------------------------------------+
//|                                          SimplySpecification.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

//https://www.mql5.com/en/forum/123307

string SymbolsArray[13] = {"","USDCHF","GBPUSD","EURUSD","USDJPY",
"AUDUSD","USDCAD","EURGBP","EURAUD","EURCHF","EURJPY","GBPJPY","GBPCHF"};
string pairs[28];
//+------------------------------------------------------------------+
//| string SymbolByNumber                                            |
//+------------------------------------------------------------------+
string GetSymbolString(int Number)
  {
//----
   string res = "";
   res = SymbolsArray[Number];   
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| A very simple function to calculate margin for Forex symbols.    |
//| It automatically calculates in the account's base currency and   |
//| does not work for complicated rates that do not have direct      |
//| recalculation into the trade account's base currency.            |
//+------------------------------------------------------------------+
double MarginCalculate(string symbol, double volume)
  {
   string first    = StringSubstr(symbol,0,3); // the first symbol, for example,  EUR
   string second   = StringSubstr(symbol,3,3); // the second symbol, for example, USD
   string currency = AccountCurrency();        // deposit currency, for example,  USD
   double leverage = AccountLeverage();        // leverage, for example,          100
// contract size, for example, 100000
   double contract = MarketInfo(symbol, MODE_LOTSIZE);
   double bid      = MarketInfo(symbol, MODE_BID);      // Bid price
//---- allow only standard forex symbols like XXXYYY
   if(StringLen(symbol) != 6)
     {
      Print("MarginCalculate: '",symbol,"' must be standard forex symbol XXXYYY");
      return(0.0);
     }
//---- check for data availability
   if(bid <= 0 || contract <= 0) 
     {
      Print("MarginCalculate: no market information for '",symbol,"'");
      return(0.0);
     }
//---- check the simplest variations - without cross currencies
   if(first == currency)   
       return(contract*volume / leverage);           // USDxxx
   if(second == currency)  
       return(contract*bid*volume / leverage);       // xxxUSD
//---- check normal cross currencies, search for direct conversion through deposit currency
   string base = currency + first;                // USDxxx
   if(MarketInfo(base, MODE_BID) > 0) 
       return(contract / MarketInfo(base, MODE_BID)*volume / leverage);
//---- try vice versa
   base = first + currency;                          // xxxUSD
   if(MarketInfo(base, MODE_BID) > 0) 
       return(contract*MarketInfo(base, MODE_BID)*volume / leverage);
//---- direct conversion is impossible
   Print("MarginCalculate: can not convert '",symbol,"'");
   return(0.0);
  }
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int OnStart()
  {
   Assign28SymbolToList(pairs);
//----
   for(int i = 0; i < 28; i++)
     {
      Print("Symbol=",pairs[i],"  spread=",MarketInfo(pairs[i],
      MODE_SPREAD),"  margin at 1 lot=",MarginCalculate(pairs[i],0.01),
      "  MODE_LOTSIZE=",MarketInfo(pairs[i],MODE_LOTSIZE),
      "  MODE_BID=",MarketInfo(pairs[i],MODE_BID),
      //"  MODE_POINT=", DoubleToStr(MarketInfo(pairs[i],MODE_POINT)),
      //"  MODE_DIGITS=",MarketInfo(pairs[i],MODE_DIGITS),
      "  MODE_TICKVALUE=",MarketInfo(pairs[i],MODE_TICKVALUE),
      ", MODE_TICKSIZE=",MarketInfo(pairs[i],MODE_TICKSIZE),
      " MODE_MARGINREQUIRED=",MarketInfo(pairs[i],MODE_MARGINREQUIRED));
     } 
//----
   return(0);
  }
//+------------------------------------------------------------------+


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