//+------------------------------------------------------------------+
//|                                                    CStopLoss.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

extern double atr_p = 15;                           //ATR/HiLo period for dynamic SL/TP/TS
extern double atr_x = 1;                            //ATR weight in SL/TP/TS
extern int    atr_tf = 240;
extern double hilo_x = 0.5;                         //HiLo weight in SL/TP/TS
double sl_p = 0;                                    //Raw pips offset

extern double pf = 20;                             //Targeted profit factor (x times SL)

extern bool trail_mode = false;                      //Enable trailing
extern double tf = 0.8;                             //Trailing factor (x times Sl)

class CStopLoss{

private:
   int     m_atr_period;
   double  m_atr_weight;
   int     m_atr_timeframe;
   
   int     m_ma_peroid;
   double  m_ma_weight;
   int     m_ma_timeframe;
   
   double  m_stoploss_rate;
   double  m_takeprofit_rate;
   
   string  m_symbol;
   int     m_digits;
   
public:

   CStopLoss();
   ~CStopLoss();
   void Init();
   double CalculateBase();
   double GetStopLoss();
   double GetTakeProfit();

};

CStopLoss::CStopLoss():m_atr_period(15),
                       m_atr_timeframe(0),
                       m_atr_weight(1),
                       m_ma_peroid(30),
                       m_ma_timeframe(0),
                       m_ma_weight(0.5),
                       m_symbol(NULL),
                       m_stoploss_rate(0.8),
                       m_takeprofit_rate(2.4){
   m_digits = (int)MarketInfo(m_symbol,MODE_DIGITS);
}

CStopLoss::~CStopLoss(){

}

void CStopLoss::Init(void){
   
}

double CStopLoss::CalculateBase(void){
   double atr1 = iATR(m_symbol,m_atr_timeframe,m_atr_period,0);// Period 15
   double atr2 = iATR(m_symbol,m_atr_timeframe,2*m_atr_period,0);// Period 30
   double atr3 = NormalizeDouble(((atr1+atr2)/2)*m_atr_weight,m_digits);// Atr weight 1 in SL?TP/TSL
   
   double ma1 = iMA(m_symbol,m_ma_timeframe,m_ma_peroid,0,MODE_LWMA,PRICE_HIGH,0);// 30 MA High
   double ma2 = iMA(m_symbol,m_ma_timeframe,m_ma_peroid,0,MODE_LWMA,PRICE_LOW,0);// 30 Ma Low
   double ma3 = NormalizeDouble(m_ma_weight*(ma1 - ma2),m_digits);// HiLo weight 0.5 in SL/TP/TSL
//--- SL & TP calculation 

   //double sl_p1 = NormalizeDouble(Point*sl_p/((1/(Close[0]+(spread/2)))),Digits);
   
   double SLp = atr3 + ma3;// (atr15+atr30)/2 + (ma30High-ma30Low)/2
   //double TPp = NormalizeDouble(pf*(SLp),Digits); // 3.5 SLP
   //double TSp = NormalizeDouble(tf*(SLp),Digits); //0.8 SLP
   return SLp;
}

double CStopLoss::GetStopLoss(void){
   return NormalizeDouble(m_stoploss_rate * CalculateBase(), m_digits);
}

double CStopLoss::GetTakeProfit(void){
   return NormalizeDouble(m_takeprofit_rate * CalculateBase(), m_digits);
}