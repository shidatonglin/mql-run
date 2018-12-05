struct heikenAshi {
   double haClose;
   double haOpen;
   double haHigh;
   double haLow;
   double haBoday;
   bool   isUp;
   heikenAshi() {
	   haClose = 0.0;
	   haOpen = 0.0;
	   haHigh = 0.0;
	   haLow = 0.0;
	   haBoday= 0.0;
	   isUp = false;
   }
}; 

class CHeiKenAshi{

private:

   string                _symbol;
   int                   _timeFrame;
   int                   _digits;
           
public:
   
   CHeiKenAshi(string symbol, int tf):
                     _symbol(symbol),
                     _timeFrame(tf){
      _digits = (int)MarketInfo(_symbol,MODE_DIGITS);                
   }
   
   ~CHeiKenAshi(){
   }
   
   heikenAshi Refersh(int index){
      heikenAshi ha;
      ha.haClose = iCustom(_symbol, _timeFrame, "Heiken Ashi", 0,0,0,0, 3, index);
      ha.haOpen = iCustom(_symbol, _timeFrame, "Heiken Ashi", 0,0,0,0, 2, index);
      double highlow = iCustom(_symbol, _timeFrame, "Heiken Ashi", 0,0,0,0, 0, index);
      double lowhigh = iCustom(_symbol, _timeFrame, "Heiken Ashi", 0,0,0,0, 1, index);
      ha.haHigh = MathMax(highlow, lowhigh);
      ha.haLow = MathMin(highlow, lowhigh);
      
      ha.haBoday = MathAbs(ha.haOpen - ha.haClose);
      ha.isUp = (ha.haClose-ha.haOpen)>0 ? true : false;
      return ha;
   }
};