//+------------------------------------------------------------------+
//|                                       expert_breakeven_ha_ma.mqh |
//|                                                   Enrico Lambino |
//|                             https://www.mql5.com/en/users/iceron |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino."
#property link      "https://www.mql5.com/en/users/iceron"
#property version   "1.00"
#property strict
#include <MQLx\Base\Expert\ExpertAdvisorsBase.mqh>
#include <Indicators\Custom.mqh>
#include <BreakSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_INTRADAY_SET
  {
   INTRADAY_SET_NONE=0,
   INTRADAY_SET_1,
   INTRADAY_SET_2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MM_TYPE
  {
   MM_FIXED=0,
   MM_FIXED_FRACTIONAL,
   MM_FIXED_RATIO,
   MM_FIXED_RISK_PER_POINT,
   MM_FIXED_RISK
  };

input ENUM_MM_TYPE mm_type=MM_FIXED_FRACTIONAL;

input double stop_loss=500;
input double take_profit=1000;
input ENUM_STOP_TYPE stop_type_main=STOP_TYPE_BROKER;

input int breakeven_value = 200;
input int breakeven_start = 200;

input int maperiod=14;
input ENUM_MA_METHOD mamethod=MODE_SMA;
input ENUM_APPLIED_PRICE maapplied=PRICE_CLOSE;
input int signal_bar=1;
input int magic_number  = 20181003;
input string expert_commnets = "GenesisExpert01";
/*
input bool time_range_enabled=true;
input datetime time_range_start=0;
input datetime time_range_end= 0;
input bool time_days_enabled = true;
input bool sunday_enabled = false;
input bool monday_enabled = true;
input bool tuesday_enabled= true;
input bool wednesday_enabled= true;
input bool thursday_enabled = true;
input bool friday_enabled=false;
input bool saturday_enabled=false;
input bool timer_enabled= true;
input int timer_minutes = 10080;
input ENUM_INTRADAY_SET time_intraday_set=INTRADAY_SET_1;
input int time_intraday_gmt=0;

input int intraday1_hour_start=8;
input int intraday1_minute_start=0;
input int intraday1_hour_end=17;
input int intraday1_minute_end=0;

input int intraday2_hour1_start=8;
input int intraday2_minute1_start=0;
input int intraday2_hour1_end=12;
input int intraday2_minute1_end=0;

input int intraday2_hour2_start=13;
input int intraday2_minute2_start=0;
input int intraday2_hour2_end=17;
input int intraday2_minute2_end=0;
input string savefile="save.dat";

*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiHA: public CiCustom
  {
public:
                     CiHA(void);
                    ~CiHA(void);
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const ENUM_INDICATOR type,const int num_params,const MqlParam &params[],const int buffers);
   double            GetData(const int buffer_num,const int index) const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiHA::CiHA(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiHA::~CiHA(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiHA::Create(const string symbol,const ENUM_TIMEFRAMES period,const ENUM_INDICATOR type,const int num_params,const MqlParam &params[],const int buffers)
  {
   NumBuffers(buffers);
   if(CIndicator::Create(symbol,period,type,num_params,params))
      return Initialize(symbol,period,num_params,params);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiHA::GetData(const int buffer_num,const int index) const
  {
#ifdef __MQL5__
   return CiCustom::GetData(buffer_num,index);
#else
   return iCustom(m_symbol,m_period,m_params[0].string_value,buffer_num,index);
#endif
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SignalHA: public CSignal
  {
protected:
   CiHA             *m_ha;
   CSymbolInfo      *m_symbol;
   string            m_symbol_name;
   int               m_signal_bar;
   double            m_open;
   double            m_close;
public:
   void              SignalHA(const string symbol,const ENUM_TIMEFRAMES timeframe,const int numparams,const MqlParam &params[],const int bar);
   void             ~SignalHA();
   virtual bool      Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL);
   virtual bool      Calculate(void);
   virtual void      Update(void);
   virtual bool      LongCondition(void);
   virtual bool      ShortCondition(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalHA::SignalHA(const string symbol,const ENUM_TIMEFRAMES timeframe,const int numparams,const MqlParam &params[],const int bar)
  {
   m_symbol_name= symbol;
   m_signal_bar = bar;
   m_ha=new CiHA();
   m_ha.Create(symbol,timeframe,IND_CUSTOM,numparams,params,4);
   m_indicators.Add(m_ha);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalHA::~SignalHA(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalHA::Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL)
  {
   if(CSignal::Init(symbol_man,event_man))
     {
      if(CheckPointer(m_symbol_man))
        {
         m_symbol=m_symbol_man.Get();
         if(CheckPointer(m_symbol))
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalHA::Calculate(void)
  {
#ifdef __MQL5__
   m_open=m_ha.GetData(0,signal_bar);
#else
   m_open=m_ha.GetData(2,signal_bar);
#endif
   m_close=m_ha.GetData(3,signal_bar);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalHA::Update(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalHA::LongCondition(void)
  {
   return m_open<m_close;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalHA::ShortCondition(void)
  {
   return m_open>m_close;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SignalMA: public CSignal
  {
protected:
   CiMA             *m_ma;
   CSymbolInfo      *m_symbol;
   string            m_symbol_name;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_signal_bar;
   double            m_close;
public:
   void              SignalMA(const string symbol,const ENUM_TIMEFRAMES timeframe,const int period,const int shift,const ENUM_MA_METHOD method,const ENUM_APPLIED_PRICE applied,const int bar);
   virtual bool      Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL);
   virtual bool      Calculate(void);
   virtual void      Update(void);
   virtual bool      LongCondition(void);
   virtual bool      ShortCondition(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalMA::SignalMA(const string symbol,const ENUM_TIMEFRAMES timeframe,const int period,const int shift,const ENUM_MA_METHOD method,const ENUM_APPLIED_PRICE applied,const int bar)
  {
   m_symbol_name=symbol;
   m_timeframe=timeframe;
   m_signal_bar=bar;
   m_ma=new CiMA();
   m_ma.Create(symbol,timeframe,period,0,method,applied);
   m_indicators.Add(m_ma);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalMA::Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL)
  {
   if(CSignal::Init(symbol_man,event_man))
     {
      if(CheckPointer(m_symbol_man))
        {
         m_symbol=m_symbol_man.Get();
         if(CheckPointer(m_symbol))
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalMA::Calculate(void)
  {
   double close[];
   if(CopyClose(m_symbol_name,m_timeframe,signal_bar,1,close)>0)
     {
      m_close=close[0];
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalMA::Update(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalMA::LongCondition(void)
  {
   return m_close>m_ma.Main(m_signal_bar);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalMA::ShortCondition(void)
  {
   return m_close<m_ma.Main(m_signal_bar);
  }
CExpertAdvisors experts;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CExpertAdvisor *expert=new CExpertAdvisor();
   expert.Name("RenkoExpert");
   expert.Comment(expert_commnets);
   expert.Init(Symbol(),Period(),magic_number,false,true,false);
   //expert.MaxOrders(6);
   //expert.MaxTrades(-1);
   CMoneys *money_manager=new CMoneys();
   CMoney *money_fixed=new CMoneyFixedLot(0.01);
   CMoney *money_ff=new CMoneyFixedFractional(5);
   CMoney *money_ratio=new CMoneyFixedRatio(0,0.1,1000);
   CMoney *money_riskperpoint=new CMoneyFixedRiskPerPoint(0.1);
   CMoney *money_risk=new CMoneyFixedRisk(100);

   money_manager.Add(money_fixed);
   money_manager.Add(money_ff);
   money_manager.Add(money_ratio);
   money_manager.Add(money_riskperpoint);
   money_manager.Add(money_risk);
   expert.AddMoneys(money_manager);
   /*
   CTimes *time_filters=new CTimes();
   if(time_range_enabled && time_range_end>0 && time_range_end>time_range_start)
     {
      CTimeRange *timerange=new CTimeRange(time_range_start,time_range_end);
      time_filters.Add(GetPointer(timerange));
     }
   if(time_days_enabled)
     {
      CTimeDays *timedays=new CTimeDays(sunday_enabled,monday_enabled,tuesday_enabled,wednesday_enabled,thursday_enabled,friday_enabled,saturday_enabled);
      time_filters.Add(GetPointer(timedays));
     }
   if(timer_enabled)
     {
      CTimer *timer=new CTimer(timer_minutes*60);
      timer.TimeStart(TimeCurrent());
      time_filters.Add(GetPointer(timer));
     }

   switch(time_intraday_set)
     {
      case INTRADAY_SET_1:
        {
         CTimeFilter *timefilter=new CTimeFilter(time_intraday_gmt,intraday1_hour_start,intraday1_hour_end,intraday1_minute_start,intraday1_minute_end);
         time_filters.Add(timefilter);
         break;
        }
      case INTRADAY_SET_2:
        {
         CTimeFilter *timefilter=new CTimeFilter(0,0,0);
         timefilter.Reverse(true);
         CTimeFilter *sub1 = new CTimeFilter(time_intraday_gmt,intraday2_hour1_start,intraday2_hour1_end,intraday2_minute1_start,intraday2_minute1_end);
         CTimeFilter *sub2 = new CTimeFilter(time_intraday_gmt,intraday2_hour2_start,intraday2_hour2_end,intraday2_minute2_start,intraday2_minute2_end);
         timefilter.AddFilter(sub1);
         timefilter.AddFilter(sub2);
         time_filters.Add(timefilter);
         break;
        }
      default: break;
     }
   //expert.AddTimes(GetPointer(time_filters));
   */
   CStops *stops=new CStops();
   CStop *main=new CStop("main");
   main.StopType(stop_type_main);
   main.VolumeType(VOLUME_TYPE_PERCENT_TOTAL);
   main.Main(true);
   main.StopLoss(stop_loss);
   main.TakeProfit(take_profit);
   stops.Add(GetPointer(main));

   CTrails *trails=new CTrails();
   CTrail *trail=new CTrail();
   trail.Set(breakeven_value,breakeven_start,0);
   trails.Add(trail);
   main.Add(trails);

   expert.AddStops(GetPointer(stops));

   expert.Magic(expert_commnets);
/*
   MqlParam params[1];
   params[0].type=TYPE_STRING;
#ifdef __MQL5__
   params[0].string_value="Examples\\Heiken_Ashi";
#else
   params[0].string_value="Heiken Ashi";
#endif
   SignalHA *signal_ha=new SignalHA(Symbol(),0,1,params,signal_bar);*/
   SignalRenko *signal_renko =new SignalRenko(Symbol(),0,maperiod,0,mamethod,maapplied,signal_bar);

   SignalMA *signal_ma=new SignalMA(Symbol(),0,5,2,MODE_EMA,maapplied,signal_bar);
   signal_ma.Entry(false);
   signal_ma.Exit(true);
   CSignals *signals=new CSignals();
   signals.Add(GetPointer(signal_renko));
   signals.Add(GetPointer(signal_ma));
   //signals.NewSignal(false);
   
   expert.AddSignal(GetPointer(signals));
   experts.Add(GetPointer(expert));
   if(!experts.InitComponents())
      return(INIT_FAILED);
   /*   
   for(int i=0;i<experts.Total();i++)
     {
      CExpertAdvisor *e=experts.At(i);
      Print("e.MaxOrders()-->",e.MaxOrders(), "-->", e.MaxTrades());
      e.OnTick();
     }
   */
   /*
   file.Open(savefile,FILE_READ);
   if(!experts.Load(file.Handle()))
      return(INIT_FAILED);
   file.Close();
   */
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //file.Open(savefile,FILE_WRITE);
   //experts.OnDeinit(reason,file.Handle());
   //file.Close();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---   
   //experts.OnTick();
   experts.OnTick();
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SignalRenko: public CSignal
  {
protected:
   CiMA             *m_ma;
   CSymbolInfo      *m_symbol;
   BreakSignal       m_renko;
   string            m_symbol_name;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_signal_bar;
   double            m_close;
   int               m_renko_signal;
public:
   void              SignalRenko(const string symbol,const ENUM_TIMEFRAMES timeframe,const int period,const int shift,const ENUM_MA_METHOD method,const ENUM_APPLIED_PRICE applied,const int bar);
   virtual bool      Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL);
   virtual bool      Calculate(void);
   virtual void      Update(void);
   virtual bool      LongCondition(void);
   virtual bool      ShortCondition(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalRenko::SignalRenko(const string symbol,const ENUM_TIMEFRAMES timeframe,const int period,const int shift,const ENUM_MA_METHOD method,const ENUM_APPLIED_PRICE applied,const int bar)
  {
   m_symbol_name=symbol;
   m_timeframe=timeframe;
   m_signal_bar=bar;
   m_ma=new CiMA();
   m_ma.Create(symbol,timeframe,period,0,method,applied);
   m_indicators.Add(m_ma);
   m_renko_signal = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalRenko::Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL)
  {
   if(CSignal::Init(symbol_man,event_man))
     {
      if(CheckPointer(m_symbol_man))
        {
         m_symbol=m_symbol_man.Get();
         if(CheckPointer(m_symbol))
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalRenko::Calculate(void)
  {
  /*
   double close[];
   if(CopyClose(m_symbol_name,m_timeframe,signal_bar,1,close)>0)
     {
      m_close=close[0];
      return true;
     }
   return false;
   
   */
   m_renko_signal = m_renko.GetGenesisSignal(signal_bar);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalRenko::Update(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalRenko::LongCondition(void)
  {
   //return m_close>m_ma.Main(m_signal_bar);
   return m_renko_signal == 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalRenko::ShortCondition(void)
  {
   //return m_close<m_ma.Main(m_signal_bar);
   return m_renko_signal == -1;
  }