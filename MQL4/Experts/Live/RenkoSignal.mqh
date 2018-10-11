//+------------------------------------------------------------------+
//|                                                  RenkoSignal.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

class RenkoSignal{

private:

   string      m_symbol;
   double      m_size;
   int         m_ma_period;
   int         m_ma_shift;
   int         m_ma_method;
   int         m_ma_price;
   int         m_consistent;
   int         m_reverse;
   double      m_digits;
   
public:

   RenkoSignal();
   ~RenkoSignal();
   int GetRenkoSignal(int);
   bool CheckBuySignal(int);
   bool CheckSellSignal(int);
   bool IsBuyBar(int);
   bool IsSellBar(int);
};

RenkoSignal::RenkoSignal(void):m_symbol(NULL),
                               m_size(10),
                               m_ma_period(5),
                               m_ma_shift(2),
                               m_ma_method(MODE_EMA),
                               m_ma_price(PRICE_CLOSE),
                               m_consistent(3),
                               m_reverse(1){
   m_digits = MarketInfo(m_symbol,MODE_DIGITS);
}


RenkoSignal::~RenkoSignal(){

}

int RenkoSignal::GetRenkoSignal(int shift){
   if(CheckBuySignal(shift)) return 1;
   else if(CheckSellSignal(shift)) return -1;
   return 0;
}

bool RenkoSignal::CheckBuySignal(int shift){
   //if(IsBuyBar(shift) && IsSellBar(shift + 1)){
   if(IsBuyBar(shift)){
      int index = 1;
      while(index <= m_reverse){
         if(IsBuyBar(index + shift)) return false;
         index++;
      }
      for(int i = 0; i < m_consistent; i++){    
         if(IsSellBar(i+index+shift)) return false; 
      }
      return true;
   }
   return false;
}

bool RenkoSignal::CheckSellSignal(int shift){
   //if(IsSellBar(shift) && IsBuyBar(shift + 1)){
   if(IsSellBar(shift)){
      int index = 1;
      while(index <= m_reverse){
         if(IsSellBar(index + shift)) return false;
         index++;
      }
      for(int i = 0; i < m_consistent; i++){
         if(IsBuyBar(i+index+shift)) return false;
      }
      return true;
   }
   return false;
}

bool RenkoSignal::IsBuyBar(int shift){
   return (Close[shift] > Open[shift]);
}

bool RenkoSignal::IsSellBar(int shift){
   return (Close[shift] < Open[shift]);
}

