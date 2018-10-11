//+------------------------------------------------------------------+
//|                                                      PowerSM.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#define buy 1
#define sell -1
#define none 0
#define prefix "PowerGrid"
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
class LastOrder
  {

public:

   bool              m_live;
   double            m_lots;
   double            m_open_price;
   //double m_index;
   int               m_ticket;  // As the key of the order
   double            m_profit;
   int               m_type;
   int               m_magic;
   string            m_comments;
   //int    m_key;

protected:

   void orderinfo()
     {
      if(OrderSelect(m_ticket,SELECT_BY_TICKET))
        {
         m_lots=OrderLots();
         m_open_price=OrderOpenPrice();
         m_magic=OrderMagicNumber();
         m_profit=OrderProfit();
         m_type=OrderType();
         // OrderCloseTime() > 0 The select order closed
         // OrderCloseTime() == 0 Open or pending orders
         m_live=OrderCloseTime()>0 ? false : true;
         m_comments=OrderComment();
        }
     }

public:

                     LastOrder(){}
                    ~LastOrder(){}

   void init(int ticket)
     {
      m_ticket=ticket;
      if(m_ticket>0)
        {
         orderinfo();
        }
     }

   bool refresh()
     {
      if(OrderSelect(m_ticket,SELECT_BY_TICKET))
        {
         m_profit=OrderProfit();
         // OrderCloseTime() > 0 The select order closed
         // OrderCloseTime() == 0 Open or pending orders
         m_live=OrderCloseTime()>0 ? false : true;
         return true;
        }
      return false;
     }
  };

LastOrder orders_buy[12];
LastOrder orders_sell[12];
int buy_index;
int sell_index;

double lotsteps[]=
  {
   0.1,0.1,0.2,0.3,0.4,0.6,0.8,1.1,1.5,2.0,2.7
      ,3.6,4.7,6.2,8.0,10.2,13.0,16.5,20.8,26.3,33.1
      ,41.6,52.2,65.5,82.5,103.9,130.9,165,207.9,262
      ,330.1,416,524.7,661.1
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PowerSM
  {

private:

   string            m_symbol;
   int               m_timeframe;
   bool              m_init;
   int               m_max_order;
   int               m_index_buy;
   int               m_index_sell;
   double            m_profit;
   double            m_step;
   double            m_step_factor;

   int               m_magic;
   string            m_comments_buy;
   string            m_comments_sell;
   double            m_start_lots;
   double            m_lots_factor;

   int               m_signal;

   int               m_current_order_type;
   int               m_current_order_number;

   int               m_rsi_period;
   int               m_rsi_shift;
   int               m_rsi_lower;
   int               m_rsi_upper;

   int               m_buy_ticket;
   int               m_sell_ticket;

public:

                     PowerSM():m_init(false),
                                   m_max_order(5),
                                   m_index_buy(0),
                                   m_index_sell(0),
                                   m_profit(10),
                                   m_start_lots(0.01),
                                   m_lots_factor(1),
                                   m_step(100),
                                   m_step_factor(1),
                                   m_signal(none),
                                   m_current_order_type(none),
                                   m_current_order_number(0),
                                   m_rsi_period(14),
                                   m_rsi_shift(1),
                                   m_rsi_lower(30),
                                   m_rsi_upper(70){}
                    ~PowerSM(){}

   void init(string symbol,int timeframe)
     {
      m_symbol=symbol;
      m_timeframe=timeframe;
      m_init=true;
     }

   void maxOrder(int max){m_max_order=max;}
   void profit(double profit){m_profit=profit;}
   void magicNum(int magic){m_magic=magic;}
   void rsi(int period,int shift,int upper=70,int lower=30)
     {
      m_rsi_period= period;
      m_rsi_shift = shift;
      m_rsi_lower = lower;
      m_rsi_upper = upper;
     }
   void step(double step,double step_factor)
     {
      m_step=step;
      m_step_factor=step_factor;
     }
   void setLots(double startlots,double lotfactor)
     {
      m_start_lots=startlots;
      m_lots_factor=lotfactor;
     }

   bool validate_settings()
     {
      // Max Order Setting Check
      if(m_max_order<1)
        {
         Print("Max Order Setting Error : ",m_max_order);
         return false;
        }
      double minlot=MarketInfo(Symbol(),MODE_MINLOT);
      //double stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
      if(m_start_lots<minlot)
        {
         Print("Start lots is too small : ",m_start_lots);
         return false;
        }
      return true;
     }

   int get_signal()
     {
      double rsi=iRSI(m_symbol,m_timeframe,m_rsi_period,PRICE_CLOSE,m_rsi_shift);
      double rsi1=iRSI(m_symbol,m_timeframe,m_rsi_period,PRICE_CLOSE,m_rsi_shift+1);
      double rsi2=iRSI(m_symbol,m_timeframe,m_rsi_period,PRICE_CLOSE,m_rsi_shift+2);
      if(rsi>m_rsi_upper
         && ((rsi-rsi1)<(rsi1-rsi2)
         || (rsi<rsi1 && rsi1 > rsi2))) return sell;
      if(rsi<m_rsi_lower
         && (MathAbs((rsi-rsi1))<MathAbs((rsi1-rsi2))
         || (rsi>rsi1 && rsi1 < rsi2))) return buy;
      return none;
     }

   void getCurrentOrder()
     {
      int total=OrdersTotal();
      string comment="";
      m_current_order_number=0;
      for(int i=0; i<total; i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()!=m_symbol || OrderMagicNumber()!=m_magic) continue;
         comment=OrderComment();
         if(OrderType()==OP_BUY) 
           {
            m_current_order_type=buy;
            m_index_buy = MathMax(m_index_buy,StringToInteger(StringSubstr(comment,StringFind(comment,"_")+1)));
            m_index_buy+= 1;
           }
         if(OrderType()==OP_SELL)
           {
            m_current_order_type=sell;
            m_index_sell = MathMax(m_index_sell,StringToInteger(StringSubstr(comment,StringFind(comment,"_")+1)));
            m_index_sell+= 1;
           }

         m_current_order_number+=1;
        }
     }

   void process()
     {
/*
      if(!validate_settings()){
         return;
      }
      */

      getCurrentOrder();

      if(buy_index==0 || (buy_index==m_max_order -1 && m_current_order_number==0))
        {
         resetBasket(buy);
        }

      if(sell_index==0 || (sell_index==m_max_order -1 && m_current_order_number==0))
        {
         resetBasket(sell);
        }

      //bool new_circle = (buy_index==0 || sell_index == 0);
      //if(m_current_order_number == 0){
      //if(new_circle){

      if(buy_index==0)check_open(buy);
      else check_add(buy);

      if(sell_index==0)check_open(sell);
      else check_add(sell);

      //} else {
      if(!check_close())
        {
         //check_add();
        }

      //}
     }

   void check_open(int type)
     {
      m_signal=get_signal();
      if(type==buy && m_signal==buy)
        {
         if(check_open_buy())
           {
            open_new(buy);
           }
        }

      if(type==sell && m_signal==sell)
        {
         if(check_open_sell())
           {
            open_new(sell);
           }
        }
     }

   bool check_open_buy()
     {
      if(iClose(m_symbol,m_timeframe,1)>iOpen(m_symbol,m_timeframe,1))
        {
         return true;
        }
      return false;
     }

   bool check_open_sell()
     {
      if(iClose(m_symbol,m_timeframe,1)<iOpen(m_symbol,m_timeframe,1))
        {
         return true;
        }
      return false;
     }

   void open_new(int type,string comments="")
     {
      if(comments=="")
        {
         m_comments_buy=IntegerToString(TimeCurrent())+"_"+IntegerToString(buy_index);
         m_comments_sell=IntegerToString(TimeCurrent())+"_"+IntegerToString(sell_index);
        }
      if(type==buy)OpenBuyOrder(m_lots_factor * lotsteps[buy_index],0,0,m_comments_buy,m_magic);
      if(type==sell)OpenSellOrder(m_lots_factor * lotsteps[sell_index],0,0,m_comments_sell,m_magic);
     }

   //------------------------------------------------------------------------------------
   //  Open a new buy order
   //------------------------------------------------------------------------------------
   int OpenBuyOrder(double lotSize,double sl=0,double tp=0,string cmd="",int magic=1234)
     {
      RefreshRates();
      double price=MarketInfo(m_symbol,MODE_ASK);
      Print(m_symbol," Open buy order lots:",lotSize," price:",price,"  sl:",sl," tp:",tp);
      int ticket=OrderSend(m_symbol,OP_BUY,lotSize,price,3,sl,tp,cmd,magic);
      if(ticket<0)
        {
         int ErrNumber=GetLastError();
         Print("  buy order failed err# ",ErrNumber," symbol:",m_symbol," lots:",lotSize," price:",price," sl:",sl,"  tp:",tp);
           } else {
         m_buy_ticket=ticket;
         pushOrders(ticket,buy);
        }

      return ticket;
     }

   //------------------------------------------------------------------------------------
   //  Open a new sell order
   //------------------------------------------------------------------------------------
   int OpenSellOrder(double lotSize,double sl=0,double tp=0,string cmd="",int magic=1234)
     {
      RefreshRates();
      double price=MarketInfo(m_symbol,MODE_BID);
      Print(m_symbol," Open sell order for lots:",lotSize," price:",price,"  sl:",sl," tp:",tp);
      int ticket=OrderSend(m_symbol,OP_SELL,lotSize,price,3,sl,tp,cmd,magic);
      if(ticket<0)
        {
         int ErrNumber=GetLastError();
         Print("  sell order failed err# ",ErrNumber," symbol:",m_symbol," lots:",lotSize," price:",price," sl:",sl,"  tp:",tp);
           }else {
         m_sell_ticket=ticket;
         pushOrders(ticket,sell);
        }

      return ticket;
     }

   void check_add(int type)
     {
      getCurrentOrder();
      double last_open;
      string last_comments;
      if(type==buy)
        {
         last_open=orders_buy[buy_index].m_open_price;
         last_comments=orders_buy[buy_index].m_comments;
         if(last_open-MarketInfo(m_symbol,MODE_ASK)
            >=GetPipstepForStep(buy_index+1)*MarketInfo(m_symbol,MODE_POINT))
           {
            if(check_open_buy())
              {
               open_new(buy,StringSubstr(last_comments,0,StringFind(last_comments,"_"))
                        +IntegerToString(buy_index));
              }
           }
           }else if(type==sell){
         last_open = orders_sell[sell_index].m_open_price;
         last_comments=orders_sell[buy_index].m_comments;
         if(MarketInfo(m_symbol,MODE_BID)-last_open
            >=GetPipstepForStep(sell_index+1)*MarketInfo(m_symbol,MODE_POINT))
           {
            if(check_open_sell())
              {
               open_new(sell,StringSubstr(last_comments,0,StringFind(last_comments,"_"))
                        +IntegerToString(sell_index));
              }
           }
        }

     }

   double GetPipstepForStep(int CurrStep)
     {
      double CurrPipstep=NormalizeDouble(m_step*MathPow(m_step_factor,CurrStep),0);
      return(CurrPipstep);
     }

   bool check_close()
     {
      return false;
     }

   void pushOrders(int ticket,int type)
     {
      if(ticket < 0) return;
      if(type==buy)
        {
         //ArrayResize(orders_buy, buy_index + 1);
         Print("buy_index=",buy_index);
         Print("ArraySize=",ArraySize(orders_buy));
         orders_buy[buy_index].init(ticket);
         buy_index++;
        }
      if(type==sell)
        {
         orders_sell[sell_index].init(ticket);
         sell_index++;
        }
     }

   void resetBasket(int type)
     {
      if(type==buy)
        {
         buy_index=0;
         //ArrayFree(orders_buy);
         for(int i=0;i<ArraySize(orders_buy);i++)
           {
            orders_buy[i].init(-1);
           }
           } else if(type==sell){
         sell_index = 0;
         //ArrayFree(orders_sell);
         for(int i=0;i<ArraySize(orders_sell);i++)
           {
            orders_sell[i].init(-1);
           }
        }
     }
  };
//+------------------------------------------------------------------+
