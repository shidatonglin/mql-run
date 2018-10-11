//+------------------------------------------------------------------+
//|                                                HABreakSignal.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "CBBMACD.mqh"
/*
For Ha break signal


TimeFrame H4

Rules for buy:
1. Ha color changed from Red to White (last three changed candles)
2. Ha price cross over the Ma line (last three cross over candles)
The current bar close over the Ma line and within three bars, there is a candle
close below the Ma line.
3. The 0.6 lagu value start to bigger than the 0.8 lagu value



*/
#define IND_ASCTREND  "ASCTrend1i"
const int MAX_SEARCH_BAR = 20;

class BreakSignal{

private:

//   int     m_period_ma;
//   int     m_shift_ma;
   string  m_symbol;
   int     m_timeframe;
   int     m_digits;
   double  m_gamma_small;
   double  m_gamma_big;
   int          m_ma_period;        // MA averaging period
   int          m_ma_shift;         // MA shift
   int          m_ma_method;        // averaging method
   int          m_ma_applied_price;    // applied price
   CBbMacd *    m_bbmacd;
   const string  m_genesis_name;

public:
   BreakSignal(void);
   BreakSignal(string, int);
   ~BreakSignal();

   bool   Init(string, int);
   void   InitLagu(double, double);
   void   InitMa(int,int,int,int);//---

   string Symbol();
   void   Symbol(string symbol);
   int    TimeFrame();
   void   TimeFrame(int);
   double GetHaOpen(int);
   double GetHaClose(int);
   int    GetBuySignal(int, int);
   int    GetSellSignal(int, int);
   int    GetLastBullishBar(int);
   int    GetLastBearishBar(int);
   int    GetLastBarBelowMA(int);
   int    GetLastBarUpMA(int);
   int    GetLastCrossBarIndex(int, int);

   double GetLaguMain(double, int);
   double GetMaValue(int);
   int    GetSignal();
   //double GetHaHigh(int);
   //double GetHaLow(int);
//   double GetMaValue(int,int);
   bool   IsBbMacdUp(int);
   bool   IsBbMacdDown(int);
   bool   IsGenesisUp(int shift);
   bool   IsGenesisDown(int shift);
   int    GetLastGenesisRangeBarIndex(int, int);
   int    GetGenesisBuySignal(int);
   int    GetGenesisSellSIgnal(int);
   int    GetGenesisSignal(int, int);
   bool   IsBbMacdBandExtend(int);

   int    GetAscTrendSignal(int);
   int    GetAscTrendTwoTFSignal(int, int, int);

};

BreakSignal::BreakSignal(void):m_symbol(NULL),
                               m_timeframe(PERIOD_H4),
                               m_gamma_small(0.6),
                               m_gamma_big(0.75),
                               m_ma_applied_price(PRICE_CLOSE),
                               m_ma_method(MODE_EMA),
                               m_ma_period(5),
                               m_ma_shift(2),
                               m_genesis_name("GenesisMatrix 2.22")
{
   m_digits = (int)MarketInfo(m_symbol, MODE_DIGITS);
   //string symbol, int fast, int slow, int signal, double stdvalue, int tf=0
   m_bbmacd = new CBbMacd(m_symbol, 12, 26, 10, 1, m_timeframe);
}

BreakSignal::BreakSignal(string symbol, int timeframe):m_symbol(symbol),
                                                        m_timeframe(timeframe),
                                                        m_gamma_small(0.6),
                                                        m_gamma_big(0.75),
                                                        m_ma_applied_price(PRICE_CLOSE),
                                                        m_ma_method(MODE_EMA),
                                                        m_ma_period(5),
                                                        m_ma_shift(2),
                                                        m_genesis_name("GenesisMatrix 2.22")
{
   m_digits = (int)MarketInfo(m_symbol, MODE_DIGITS);
   m_bbmacd = new CBbMacd(m_symbol, 12, 26, 10, 1, m_timeframe);
}

BreakSignal::~BreakSignal(void){
    delete m_bbmacd;
}

bool BreakSignal::Init(string symbol, int timeframe){
    m_symbol = symbol;
    m_timeframe = timeframe;
    m_digits = (int)MarketInfo(m_symbol, MODE_DIGITS);
    return true;
}

void BreakSignal::InitLagu(double gamma_big, double gamma_small){
   m_gamma_big = gamma_big;
   m_gamma_small = gamma_small;
}

void BreakSignal::InitMa(int period, int shift, int mode, int price){
   m_ma_period = period;
   m_ma_shift = shift;
   m_ma_method = mode;
   m_ma_applied_price = price;
}

string BreakSignal::Symbol(){
    return m_symbol;
}

void BreakSignal::Symbol(string symbol){
    m_symbol = symbol;
}

int BreakSignal::TimeFrame(void){
   return m_timeframe;
}

void BreakSignal::TimeFrame(int timeframe){
   m_timeframe = timeframe;
}


//bool BreakSignal::InitMa(int period, int shift){
//   m_shift_ma = shift;
//   m_period_ma = period;
//   return true;
//}

//double BreakSignal::GetMaValue(int barShift){
//   return iMA(m_symbol, m_timeframe, m_period_ma, m_shift_ma, MODE_EMA,PRICE_CLOSE,barShift);
//}

double BreakSignal::GetHaOpen(int shift=1){
	return NormalizeDouble(iCustom(m_symbol, m_timeframe, "Heiken Ashi", 0,0,0,0, 2, shift),m_digits);
}

double BreakSignal::GetHaClose(int shift=1){
	return NormalizeDouble(iCustom(m_symbol, m_timeframe, "Heiken Ashi", 0,0,0,0, 3, shift),m_digits);
}

int BreakSignal::GetBuySignal(int maxBarShift, int shift = 1){

    // For buy signal
    bool barColorChange = false;
    int lastChangeBar = GetLastBearishBar(shift);

    if(GetHaClose(shift) > GetHaOpen(shift)   // Buy Bar
        && lastChangeBar != -1               //
        && lastChangeBar <= (maxBarShift + shift)
    ){
        barColorChange = true;
    }

    bool maCrossed = false;
    //double maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,shift);
    double maValue = GetMaValue(shift);
    if(GetHaClose(shift) > maValue
        && GetLastBarBelowMA(shift) != -1
        && GetLastBarBelowMA(shift) <= (maxBarShift + shift)){
        maCrossed = true;
    }

    bool laguCross = false;
    double laguSignal = GetLaguMain(m_gamma_small,shift);
    double laguMain   = GetLaguMain(m_gamma_big,shift);
    //Print("shift-->",shift);
    //Print("laguSignal-->",laguSignal);
    //Print("laguMain-->",laguMain);
    if(laguSignal > laguMain
        && GetLastCrossBarIndex(1,shift) != -1
        && GetLastCrossBarIndex(1,shift) < (maxBarShift + shift)){
        laguCross = true;
    }

    //Print("barColorChange-->",barColorChange);

    //Print("maCrossed-->",maCrossed);

    //Print("laguCross-->",laguCross);

    if(barColorChange && maCrossed && laguCross){
        return 1;
    } else {
        return 0;
    }
}

int BreakSignal::GetSellSignal(int maxBarShift, int shift = 1){
    // For Sell signal
    bool barColorChange = false;
    int lastChangeBar = GetLastBullishBar(shift);
    //Print("lastChangeBar-->",lastChangeBar);
    //Print("GetHaClose(shift)-->",GetHaClose(shift));
    //Print("GetHaOpen(shift)-->",GetHaOpen(shift));
    if(GetHaClose(shift) < GetHaOpen(shift)   // Buy Bar
        && lastChangeBar != -1               //
        && lastChangeBar <= (maxBarShift + shift)
    ){
        barColorChange = true;
    }

    bool maCrossed = false;
    //double maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,shift);
    double maValue = GetMaValue(shift);
    //Print("maValue-->",maValue);
    //Print("GetHaClose(shift)-->",GetHaClose(shift));
    //Print("GetLastBarUpMA(shift)-->",GetLastBarUpMA(shift));
    if(GetHaClose(shift) < maValue
        && GetLastBarUpMA(shift) != -1
        && GetLastBarUpMA(shift) <= (maxBarShift + shift)){
        maCrossed = true;
    }

    bool laguCross = false;
    double laguSignal = GetLaguMain(m_gamma_small,shift);
    double laguMain   = GetLaguMain(m_gamma_big,shift);
    //Print("laguSignal-->",laguSignal);
    //Print("laguMain-->",laguMain);
    //Print("GetLastCrossBarIndex(-1,shift)-->",GetLastCrossBarIndex(-1,shift));
    if(laguSignal < laguMain
        && GetLastCrossBarIndex(-1,shift) != -1
        && GetLastCrossBarIndex(-1,shift) <= (maxBarShift + shift)){
        laguCross = true;
    }

    //Print("barColorChange-->",barColorChange);

    //Print("maCrossed-->",maCrossed);

    //Print("laguCross-->",laguCross);

    if(barColorChange && maCrossed && laguCross){
        return 1;
    } else {
        return 0;
    }
}

int BreakSignal::GetLastBearishBar(int start = 1){
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        if(GetHaClose(i) < GetHaOpen(i)){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBullishBar(int start = 1){
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        if(GetHaClose(i) > GetHaOpen(i)){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBarBelowMA(int start = 1){
    double maValue = 0.0;
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        //maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,i);
        maValue = GetMaValue(i);
        //Print((i),"--->",maValue);
        if(GetHaClose(i) < maValue){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBarUpMA(int start = 1){
    double maValue = 0.0;
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        //maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,i);
        maValue = GetMaValue(i);
        if(GetHaClose(i) > maValue){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastCrossBarIndex(int direction, int start = 1){
    double laguSignal = 0, laguMain = 0;
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        //laguSignal = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.6, 1000,2, 0, i);
        //laguMain   = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.75,1000,2, 0, i);
        laguSignal = GetLaguMain(0.6,i);
        laguMain = GetLaguMain(0.75,i);
        //Print((i),"--->",laguSignal);
        if(direction == 1 && laguSignal <= laguMain){
            return i;
        }
        if(direction == -1 && laguSignal >= laguMain){
            return i;
        }
    }
    return -1;
}

double BreakSignal::GetLaguMain(double gamma,int shift=1){
   return NormalizeDouble(iCustom(m_symbol, m_timeframe, "Laguerre-ACS1",
                                 gamma,500,2, 0, shift),2);
}


double BreakSignal::GetMaValue(int shift=1){
   //return NormalizeDouble(iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,shift), m_digits);
   return NormalizeDouble(iMA(m_symbol, m_timeframe, m_ma_period, m_ma_shift
                              , m_ma_method ,m_ma_applied_price,shift), m_digits);
}

int BreakSignal::GetSignal(){
    if(GetBuySignal(3) > 0) return 1;
    if(GetSellSignal(3) > 0) return -1;
    return 0;
}

bool BreakSignal::IsBbMacdDown(int shift){
    m_bbmacd.Refresh(shift);
    if(!m_bbmacd.isUp(shift) && m_bbmacd.Trend(shift) == DOWN){
        return true;
    }
    return false;
}

bool BreakSignal::IsBbMacdUp(int shift){
    m_bbmacd.Refresh(shift);
    if(m_bbmacd.isUp(shift) && m_bbmacd.Trend(shift) == UP){
        return true;
    }
    return false;
}

bool BreakSignal::IsBbMacdBandExtend(int shift){
   //m_bbmacd.Refresh(shift);
   return (m_bbmacd.GetBandDistance(shift) - m_bbmacd.GetBandDistance(shift+1)) > 0;
}

bool BreakSignal::IsGenesisUp(int shift){
   string name = m_genesis_name;
   double v0 = iCustom(NULL,0,name,0,shift);
   double v2 = iCustom(NULL,0,name,2,shift);
   double v4 = iCustom(NULL,0,name,4,shift);
   double v6 = iCustom(NULL,0,name,6,shift);
   if(v0>0&&v2>0&&v4>0&&v6>0){
      return true;
   }
   return false;
}

bool BreakSignal::IsGenesisDown(int shift){
   string name = m_genesis_name;
   double v1 = iCustom(NULL,0,name,1,shift);
   double v3 = iCustom(NULL,0,name,3,shift);
   double v5 = iCustom(NULL,0,name,5,shift);
   double v7 = iCustom(NULL,0,name,7,shift);
   if(v1>0&&v3>0&&v5>0&&v7>0){
      return true;
   }
   return false;
}

int BreakSignal::GetLastGenesisRangeBarIndex(int shift, int from){
   string name = m_genesis_name;
   for(int i=shift+1; i<shift+50; i++){
      if(from==1){// Current is up
         if(iCustom(NULL,0,name,0,i)==0) return i;
         if(iCustom(NULL,0,name,2,i)==0) return i;
         if(iCustom(NULL,0,name,4,i)==0) return i;
         if(iCustom(NULL,0,name,6,i)==0) return i;
      }
      if(from == -1){ // current is down
         if(iCustom(NULL,0,name,1,i)==0) return i;
         if(iCustom(NULL,0,name,3,i)==0) return i;
         if(iCustom(NULL,0,name,5,i)==0) return i;
         if(iCustom(NULL,0,name,7,i)==0) return i;
      } 
   }
   return -1;
}

int BreakSignal::GetGenesisSignal(int shift, int maxBarShift){
   bool bbmacd_buy = false, bbmacd_sell = false;
   if(IsBbMacdUp(shift)){
      if(m_bbmacd.GetBreakUpperBandIndex(shift) < (shift + maxBarShift)
         && IsBbMacdBandExtend(shift))
         bbmacd_buy = true;   
   }else if(IsBbMacdDown(shift)){
      if(m_bbmacd.GetBreakLowerBandIndex(shift) < (shift + maxBarShift)
         && IsBbMacdBandExtend(shift))
         bbmacd_sell = true;
   }
   
   bool genesis_buy = false, genesis_sell = false;
   if(IsGenesisUp(shift)){
      if(GetLastGenesisRangeBarIndex(shift, 1) < (shift + maxBarShift))
         genesis_buy = true;
   }else if(IsGenesisDown(shift)){
      if(GetLastGenesisRangeBarIndex(shift, -1) < (shift + maxBarShift))
         genesis_sell = true;
   }
   
   if(bbmacd_buy && genesis_buy) return 1;
   else if(bbmacd_sell && genesis_sell) return -1;
   else return 0;
}

int BreakSignal::GetAscTrendSignal(int shift){
   int ascTrend = 0;
   int current = (int)iCustom(m_symbol,m_timeframe,IND_ASCTREND,6,0,2,shift);
   int previous = (int)iCustom(m_symbol,m_timeframe,IND_ASCTREND,6,0,2,shift+1);
   if(current == 1 && previous ==-1){
      ascTrend = 1;
   }
   if(current == -1 && previous == 1){
      ascTrend = -1;
   }
   
   if(IsGenesisUp(shift) && ascTrend == 1){
      return 1;
   }else if(IsGenesisDown(shift)  && ascTrend == -1){
      return -1;
   }
   return 0;
}

int BreakSignal::GetAscTrendTwoTFSignal(int lowTf, int highTf, int shift){
   int ascTrend = 0;
   int current = (int)iCustom(m_symbol,lowTf,IND_ASCTREND,6,0,2,shift);
   int previous = (int)iCustom(m_symbol,lowTf,IND_ASCTREND,6,0,2,shift+1);
   int currentHigh = (int)iCustom(m_symbol,highTf,IND_ASCTREND,6,0,2,shift);
   if(currentHigh == 1 && current == 1 && previous == -1){
      ascTrend = 1;
   }
   if(currentHigh == -1 && current == -1 && previous == 1){
      ascTrend = -1;
   }
   return ascTrend;
}
