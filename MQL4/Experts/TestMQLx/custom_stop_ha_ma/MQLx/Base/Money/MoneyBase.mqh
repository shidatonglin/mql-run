//+------------------------------------------------------------------+
//|                                                    MoneyBase.mqh |
//|                                                   Enrico Lambino |
//|                             https://www.mql5.com/en/users/iceron |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino"
#property link      "https://www.mql5.com/en/users/iceron"
#include "..\..\Common\Enum\ENUM_CLASS_TYPE.mqh"
#include "..\Symbol\SymbolManagerBase.mqh"
#include "..\Lib\AccountInfo.mqh"
#include "..\Event\EventAggregatorBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMoneyBase : public CObject
  {
protected:
   bool              m_active;
   double            m_volume;
   double            m_balance;
   double            m_balance_inc;
   int               m_period;
   bool              m_equity;
   string            m_name;
   CSymbolManager   *m_symbol_man;
   CSymbolInfo      *m_symbol;
   CAccountInfo     *m_account;
   CEventAggregator *m_event_man;
   CObject          *m_container;
public:
                     CMoneyBase(void);
                    ~CMoneyBase(void);
   virtual int       Type(void) const {return CLASS_TYPE_MONEY;}
   //--- initialization
   virtual bool      Init(CSymbolManager*,CAccountInfo*,CEventAggregator*);
   bool              InitAccount(CAccountInfo*);
   bool              InitSymbol(CSymbolManager*);
   CObject          *GetContainer(void);
   void              SetContainer(CObject*);
   virtual bool      Validate(void);
   //--- getters and setters
   bool              Active(void) const;
   void              Active(const bool);
   void              Equity(const bool);
   bool              Equity(void) const;
   void              LastUpdate(const datetime);
   datetime          LastUpdate(void) const;
   void              Name(const string);
   string            Name(void) const;
   double            Volume(const string,const double,const ENUM_ORDER_TYPE,const double);
   void              Volume(const double);
   double            Volume(void) const;
   static bool       MarginCheck(const string, const double);
protected:
   virtual void      OnLotSizeUpdated(void);
   virtual bool      UpdateLotSize(const string,const double,const ENUM_ORDER_TYPE,const double);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMoneyBase::CMoneyBase(void) : m_active(true),
                               m_volume(0.2),
                               m_period(0),
                               m_equity(false)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMoneyBase::~CMoneyBase(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMoneyBase::SetContainer(CObject *container)
  {
   m_container=container;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CObject *CMoneyBase::GetContainer(void)
  {
   return m_container;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMoneyBase::Validate(void)
  {
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMoneyBase::Active(const bool value)
  {
   m_active=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMoneyBase::Active(void) const
  {
   return m_active;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMoneyBase::Equity(const bool value)
  {
   m_equity=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMoneyBase::Equity(void) const
  {
   return m_equity;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMoneyBase::Name(const string value)
  {
   m_name=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CMoneyBase::Name(void) const
  {
   return m_name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMoneyBase::Volume(const double value)
  {
   m_volume=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMoneyBase::Volume(void) const
  {
   return m_volume;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMoneyBase::Init(CSymbolManager *symbolmanager,CAccountInfo *accountinfo,CEventAggregator *event_man=NULL)
  {
   m_event_man=event_man;
   return InitSymbol(symbolmanager) && InitAccount(accountinfo);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMoneyBase::InitSymbol(CSymbolManager *symbolmanager)
  {
   m_symbol_man=symbolmanager;   
   return CheckPointer(m_symbol_man);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMoneyBase::InitAccount(CAccountInfo *account)
  {
   m_account=account;
   return CheckPointer(m_account);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMoneyBase::Volume(const string symbol,const double price,const ENUM_ORDER_TYPE type,const double sl=0)
  {
   if(!Active())
      return 0;
   if(UpdateLotSize(symbol,price,type,sl))
      OnLotSizeUpdated();
   return m_volume;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMoneyBase::MarginCheck(const string symbol, const double volume)
  {
   string first    = StringSubstr(symbol,0,3); // the first symbol, for example,  EUR
   string second   = StringSubstr(symbol,3,3); // the second symbol, for example, USD
   string currency = AccountCurrency();        // deposit currency, for example,  USD
   double leverage = AccountLeverage();        // leverage, for example,          100
// contract size, for example, 100000
   double contract = MarketInfo(symbol, MODE_LOTSIZE);
   double bid      = MarketInfo(symbol, MODE_BID);      // Bid price
   double requiredMargin = 0.0;
//---- allow only standard forex symbols like XXXYYY
   if(StringLen(symbol) != 6)
     {
      Print("MarginCalculate: '",symbol,"' must be standard forex symbol XXXYYY");
      //return(0.0);
      return true;
     }
//---- check for data availability
   if(bid <= 0 || contract <= 0) 
     {
      Print("MarginCalculate: no market information for '",symbol,"'");
      return true;
      //return(0.0);
     }
//---- check the simplest variations - without cross currencies
   if(first == currency)   
       requiredMargin = (contract*volume / leverage);           // USDxxx
   if(second == currency)  
       requiredMargin = (contract*bid*volume / leverage);       // xxxUSD
//---- check normal cross currencies, search for direct conversion through deposit currency
   string base = currency + first;                // USDxxx
   if(MarketInfo(base, MODE_BID) > 0) 
       requiredMargin = (contract / MarketInfo(base, MODE_BID)*volume / leverage);
//---- try vice versa
   base = first + currency;                          // xxxUSD
   if(MarketInfo(base, MODE_BID) > 0) 
       requiredMargin = (contract*MarketInfo(base, MODE_BID)*volume / leverage);
   if(requiredMargin >= AccountEquity() * 0.9) {
      Print("No enough money");
      return false;
   }
//---- direct conversion is impossible
   //Print("MarginCalculate: can not convert '",symbol,"'");
   return(true);
  } 
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMoneyBase::UpdateLotSize(const string,const double,const ENUM_ORDER_TYPE,const double)
  {
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMoneyBase::OnLotSizeUpdated(void)
  {
   m_symbol = m_symbol_man.Get();
   double maxvol=m_symbol.LotsMax();
   double minvol=m_symbol.LotsMin();
   double lotstep=m_symbol.LotsStep();
   double min = MathMin(minvol,lotstep);
   if(m_volume<minvol)
      m_volume=minvol;
   if(m_volume>maxvol)
      m_volume=maxvol;   
   m_volume = NormalizeDouble(m_volume,(int)-MathLog10(min));
  }
//+------------------------------------------------------------------+
#ifdef __MQL5__
#include "..\..\MQL5\Money\Money.mqh"
#else
#include "..\..\MQL4\Money\Money.mqh"
#endif
//+------------------------------------------------------------------+
