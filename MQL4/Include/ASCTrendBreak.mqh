//+------------------------------------------------------------------+
//|                                                ASCTrendBreak.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#define IND_ASCTREND  "ASCTrend1i"

#include <CHeiKenAshi.mqh>
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

class ASCTrendBreak{

private:
   int        m_current_status;
   datetime   m_starttime;
   int        m_start_bar;
   bool       m_breaked;
   datetime   m_breaktime;
   int        m_break_index;
   string     m_symbol;
   int        m_timeframe;
   
   int        m_bb_period;
   int        m_bb_shift;
   int        m_bb_applied_price;
   double     m_bb_deviation;
   CHeiKenAshi  m_heiken;
   int        m_init_bar;
   bool       m_inited;

public:
   ASCTrendBreak();
   ~ASCTrendBreak();
   void CheckStatus(int);
   double GetASCTrendValue(int);
   double GetBollingBandValue(int, int);
   void ResetStatus(int);
   void CheckBreak(int);
   void InitStatus();
   bool UpdateBreakInfo(int);
   void PrintData();
   
   int  GetSignal(int);

protected:
   int GetAscTrendLastChangeBar(int,int);
   int GetBBLastBreakBar(int,int);
};

ASCTrendBreak::ASCTrendBreak(void):m_current_status(0),
                                    m_init_bar(1),
                                    m_starttime(NULL),
                                    m_breaked(false),
                                    m_breaktime(NULL),
                                    m_break_index(-1),
                                   m_symbol(NULL),
                                   m_timeframe(0),
                                   m_bb_period(20),
                                   m_bb_shift(0),
                                   m_bb_applied_price(PRICE_CLOSE),
                                   m_bb_deviation(1.4),
                                   m_heiken(NULL,0),
                                   m_inited(false){
   
}

ASCTrendBreak::~ASCTrendBreak(){

}

void ASCTrendBreak::CheckStatus(int shift){
/*
   int ascTrend = (int)GetASCTrendValue(shift);
   if(m_current_status != ascTrend){
      ResetStatus(ascTrend);
   }
   if(!m_breaked){
      CheckBreak(shift);
   }
*/
   //InitStatus();
}

double ASCTrendBreak::GetASCTrendValue(int shift){
   double dAscTrend=iCustom(Symbol(),0,IND_ASCTREND,6,0,2,shift);
   return dAscTrend;
}

// MODE_UPPER,MODE_LOWER
double ASCTrendBreak::GetBollingBandValue(int mode, int shift){
   return iBands(m_symbol,m_timeframe,m_bb_period,m_bb_deviation,m_bb_shift,
                  m_bb_applied_price,mode,shift);
}

void ASCTrendBreak::ResetStatus(int trend){
   m_current_status = trend;
   m_breaked = false;
   m_breaktime = NULL;
   m_starttime = iTime(m_symbol,m_timeframe,1);
}

bool ASCTrendBreak::UpdateBreakInfo(int index){
   m_breaked = true;
   m_breaktime = iTime(m_symbol,m_timeframe,index);
   return true;
}

ASCTrendBreak::CheckBreak(int index){
   if(m_breaked) return;
   heikenAshi heikenData = m_heiken.Refersh(index);
   if(m_current_status == 1 && heikenData.isUp){
      double upper = GetBollingBandValue(MODE_UPPER,index);
      if(heikenData.haClose > upper){
         UpdateBreakInfo(index);
      }
   } else if(m_current_status == -1 && !heikenData.isUp){
      double lower = GetBollingBandValue(MODE_LOWER,index);
      if(heikenData.haClose > lower){
         UpdateBreakInfo(index);
      }
   }
}

ASCTrendBreak::InitStatus(){
   m_current_status = (int)GetASCTrendValue(m_init_bar);
   m_start_bar = GetAscTrendLastChangeBar(m_init_bar + 1,m_current_status);
   if(m_start_bar != -1){
      m_starttime = iTime(m_symbol,m_timeframe,m_start_bar);
   }else {
      m_inited = false;
      return;
   }
   if(m_current_status == 1)
      m_break_index = GetBBLastBreakBar(m_init_bar,MODE_UPPER);
   else if(m_current_status == -1)
      m_break_index = GetBBLastBreakBar(m_init_bar,MODE_LOWER);
   //else lastBar = -1;
   
   if(m_break_index != -1){
      m_breaked = true;
      m_breaktime = iTime(m_symbol,m_timeframe,m_break_index);
   }
   m_inited = true;
}

int ASCTrendBreak::GetAscTrendLastChangeBar(int startbar, int trend){
   int barTrend = 0;
   for(int i=startbar; i<50+startbar;i++){
      barTrend = (int)GetASCTrendValue(i);
      if(barTrend != trend){
         return i;
      }
   }
   return -1;
}

int ASCTrendBreak::GetBBLastBreakBar(int starbar, int mode){
   double bbvalue;
   heikenAshi heikenData;
   for(int i=starbar; i< starbar+50;i++){
      heikenData = m_heiken.Refersh(i);
      bbvalue = GetBollingBandValue(mode,i);
      if(mode == MODE_UPPER){
         if(heikenData.isUp && heikenData.haClose > bbvalue){
            return i;
         }
      } else if(mode==MODE_LOWER){
         if(!heikenData.isUp && heikenData.haClose < bbvalue){
            return i;
         }
      }
   }
   return -1;
}

int ASCTrendBreak::GetSignal(int shift){
   InitStatus();
   /*
   if(m_breaked && m_breaktime == iTime(m_symbol,m_timeframe,shift)){
      return m_current_status;
   }*/
   if(m_breaked && m_break_index == shift){
      return m_current_status;
   }
   return 0;
}

void ASCTrendBreak::PrintData(){
   
}
