//+------------------------------------------------------------------+
//|                                                      FileSql.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Arrays\List.mqh>
#include <stdlib.mqh>

class ClosedPosition : public CObject
{
public:
   struct P
   {
      int               ticket;
      datetime          closed_time,open_time;
   }details;
   ClosedPosition(){}
   ClosedPosition(int ticket,datetime open_time,datetime closed_time)
     {
      this.details.ticket=ticket;
      this.details.open_time=open_time;
      this.details.closed_time=closed_time;
     }
   virtual bool Save(const int file_handle) override
     {
      if(file_handle==INVALID_HANDLE)
         return false;
      FileWriteStruct(file_handle,details);
      return true;
     }
   virtual bool Load(const int file_handle) override
     {
      if(file_handle==INVALID_HANDLE)
         return false;
      FileReadStruct(file_handle,details);
      return true;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PositionList : public CList
  {
public: virtual CObject *CreateElement(void) override { return new ClosedPosition(); }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Expert : public CObject
  {
public:
   string symbol;
   struct EA_details
     {
      ENUM_TIMEFRAMES   timeframe;
      int               magic;
     }
   details;

   struct EA_settings
     {
      int               setting1,setting2,setting3;
     }
   settings;

   PositionList      positions;

   bool deinit()
     {
      string filename=StringFormat("%s_%s_%d.bin",symbol,EnumToString(details.timeframe),details.magic);
      int f=FileOpen(filename,FILE_WRITE|FILE_BIN);
      if(f==INVALID_HANDLE)
         return false;
      if(!positions.Save(f))
         return false;
      int len = StringLen(symbol);
      FileWriteInteger(f,len);
      FileWriteString(f,symbol,len);
      FileWriteStruct(f,details);
      FileWriteStruct(f,settings);
   
      
      FileClose(f);
      return true;
     }

   bool load(string _symbol,ENUM_TIMEFRAMES _timeframe,int _magic)
     {
      string filename=StringFormat("%s_%s_%d.bin",_symbol,EnumToString(_timeframe),_magic);
      int f=FileOpen(filename,FILE_READ|FILE_BIN);
      if(f==INVALID_HANDLE)
      {
         Print(ErrorDescription(_LastError));
         return false;
      }
      if(!positions.Load(f))
         return false;
      int len = FileReadInteger(f);
      symbol = FileReadString(f,len);
      FileReadStruct(f,this.details);
      FileReadStruct(f,this.settings);
      FileClose(f);
      return true;
     }
  };
#define MAGIC 12341234
void kickoff()
  {
   Expert *e = new Expert;
   e.symbol = _Symbol;
   e.details.timeframe = (ENUM_TIMEFRAMES)_Period;
   e.details.magic = MAGIC;
   e.settings.setting1 = 1;
   e.settings.setting2 = 2;
   e.settings.setting3 = 3;
   
   for(int i=0;i<3;i++)
   {
      int ticket = 123456;
      datetime open = D'2018.05.01';
      datetime closed = D'2018.05.015';
      ClosedPosition *p = new ClosedPosition(ticket+i, open+i, closed+i);
      e.positions.Add(p);
   }
   
   // Simulating a call to deinit. There is no object in memory
   e.deinit();
   delete e;
   
   e = new Expert;
   if(e.load(_Symbol,(ENUM_TIMEFRAMES)_Period,MAGIC))
   {
      printf("%s, %s, %d", e.symbol, EnumToString(e.details.timeframe), e.details.magic);
      printf("Settings: %d, %d, %d", e.settings.setting1, e.settings.setting2, e.settings.setting3);
      for(ClosedPosition *p=e.positions.GetFirstNode(); CheckPointer(p); p = p.Next())
         printf("%d, %s = %s", p.details.ticket, 
            TimeToString(p.details.open_time), 
            TimeToString(p.details.closed_time)
         );
   }
   delete e;
   
   
   
  }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   kickoff();
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
