
//extern int   	timeFrame     = PERIOD_H4;
extern int   	fast_period   = 12;
extern int   	slow_period   = 24;
extern int      bbmacd_signal_period = 9;
extern double   std           = 1.1;

enum STATUS{
	UP,    // Main value is bigger than the upper band
	DOWN,  // Main value is smaller than the low band
	RANG   // Main value between the upper and low band
};

string BbMacd_Name = "PakuAK_Marblez";

struct bbMacdData{
   double upperBand;
   double lowerBand;
   double value;
   bool   isUp;
   STATUS trend;
   bbMacdData(){
      upperBand=0.0;
      lowerBand=0.0;
      value=0.0;
      isUp=false;
      trend=RANG;
   }
};

class CBbMacd {

	string _symbol;
	int    _timeFrame;
	int    _fastPeriod;
	int    _slowPeriod;
	int    _signalPeriod;
	double _std;

public:

	double _upperBand;
	double _lowerBand;
	double _mainValue;
	STATUS _status;
	bool   _isUp; // If the current main value bigger than the previous one


	
	// Default Constructor
	// Using the external input parameter to construct the object
	CBbMacd(string symbol, int timeFrame=PERIOD_H4) : _symbol(symbol),
				_timeFrame(timeFrame),
				_fastPeriod(fast_period),
				_slowPeriod(slow_period),
				_signalPeriod(bbmacd_signal_period),
				_std(std){
		Init();
	}

	CBbMacd(string symbol, int fast, int slow, int signalPeriod, double stdvalue, int tf=0) 
				: 	_symbol(symbol),
				    _timeFrame(tf),
					_fastPeriod(fast),
					_slowPeriod(slow),
					_signalPeriod(signalPeriod),
					_std(stdvalue){
		Init();
	}

	~CBbMacd(){}

	void Init(){
		_upperBand=0.0;
		_lowerBand=0.0;
		_mainValue=0.0;
		_status=RANG;
		_isUp=false;
	}

	bbMacdData Refresh(int shift){
		double curUp= iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 0, shift);
	    double curDown = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 1, shift);
	    _upperBand = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 2, shift);
	    _lowerBand = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 3, shift);

	    if(curUp==EMPTY_VALUE){
	    	_mainValue = curDown;
	    	_isUp=false;
    	} else {
    		_mainValue = curUp;
    		_isUp=true;
    	}

    	if(_mainValue > _upperBand){
    		_status = UP;
		} else if(_mainValue < _lowerBand){
			_status = DOWN;
		} else {
			_status = RANG;
		}
		
		bbMacdData bbMacd;
		bbMacd.upperBand =                      _upperBand;
      bbMacd.lowerBand =                  	 _lowerBand;
      bbMacd.value     =                  	 _mainValue;
      bbMacd.trend     =                  	 _status;
      bbMacd.isUp      =                  	 _isUp;
      return bbMacd;
	}

	STATUS Trend(int index){
	   //Refresh(index);
		return _status;
	}

	bool isUp(int index){
	   //Refresh(index);
		return _isUp;
	}

	double MainValue(int index){
	   //Refresh(index);
		return _mainValue;
	}
	
	double GetBandDistance(int index){
	   Refresh(index);
	   return _upperBand - _lowerBand;
	}
	
	int GetBreakUpperBandIndex(int barStart){
	   double curUp=0.0,curDown=0.0,uperBand=0.0,lowerBand=0.0,mainValue= 0.0;
	   for(int i=barStart+1; i< barStart + 30; i++){
	      curUp= iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 0, i);
   	   curDown = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
   							,_std, 1, i);
   	   uperBand = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
   							,_std, 2, i);
   	   lowerBand = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
   							,_std, 3, i);
         mainValue= 0.0;
   	   if(curUp==EMPTY_VALUE){
   	    	mainValue = curDown;
   	    	//_isUp=false;
       	} else {
       		mainValue = curUp;
       		//_isUp=true;
       	}
   
       	if(mainValue < uperBand){
       	   return i-1;
   		} 
	   }
	   return 999;
	}
	
	int GetBreakLowerBandIndex(int barStart){
	   double curUp=0.0,curDown=0.0,uperBand=0.0,lowerBand=0.0,mainValue= 0.0;
	   for(int i=barStart+1; i< barStart + 30; i++){
	      curUp= iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 0, i);
   	   curDown = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
   							,_std, 1, i);
   	   uperBand = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
   							,_std, 2, i);
   	   lowerBand = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
   							,_std, 3, i);
         mainValue= 0.0;
   	   if(curUp==EMPTY_VALUE){
   	    	mainValue = curDown;
   	    	//_isUp=false;
       	} else {
       		mainValue = curUp;
       		//_isUp=true;
       	}
   
       	if(mainValue > lowerBand){
       	   return i-1;
   		} 
      }
	   return 999;
	}
	

};






























