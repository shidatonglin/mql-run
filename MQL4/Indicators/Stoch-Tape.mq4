/*------------------------------------------------------------------------------------
   Name: Stoch-Tape.mq4
   Copyright ©2012, Xaphod, http://www.xaphod.com
   
   Description: MTF Stochastic Tape Chart Indicator.
                Features:
                - Mode 0: K over D line = rising and >Stoch_High = overbought: Blue.
                          K below D line = falling and <Stoch_Low = oversold: Red.
                  Mode 1: K line slope up = rising and >Stoch_High = overbought: Blue.
                          K line slope down = falling and <Stoch_Low = oversold: Red.

                - Divider line to group sets of lower timeframe bars to ease reading 
                  the chart.
                - Different colors for rising/overbought and falling/oversold.  

   Change log: 
       2014-02-14. v1.600
          - Update for MT4.5
          - Added Slope or KoverD selector for dulat color line. 
       2013-09-12. Xaphod, v1.10
          - Added Mode parameter. 0=Show K over D, 1=Show K Slope
          - Removed '.' from parameter variable names for future compatibility
       2012-07-16. Xaphod, v1.00 
          - First Release 
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "Copyright ©2012, xaphod.com"
#property link      "http://www.xaphod.com"
#property strict
#property version "1.600"
#property description "MTF Stochastic Tape Chart Indicator."
#property description ""
#property description "Features:"
#property description "  Linear interpolation of values between bars"
#property description "  Dots can be used to tag the closing lower time-frame bar on the line."
#property description "  Dual color to denote rising/over bought and Falling/oversold."

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 RoyalBlue
#property indicator_color2 Crimson
#property indicator_color3 Silver
#property indicator_width1  4
#property indicator_width2  4
#property indicator_width3  1
#property indicator_maximum 1
#property indicator_minimum 0

//#include <xPrint.mqh>

enum ENUM_STOCHMODE {
  KoverD=0,
  Slope=1
};

enum ENUM_AUTOTF {
  Disabled=0,
  NextTF=1,
  NextNextTF=2
};

// Constant definitions
#define INDICATOR_NAME "Stoch"
#define DIVIDER_LINE 100000

// indicator parameters
extern string    TimeFrame_Settings="——————————————————————————————"; /* Timeframe Settings */ 
extern ENUM_TIMEFRAMES  TimeFrame_Period=PERIOD_CURRENT; /* Timeframe */  // Timeframe: 0,1,5,15,30,60,240,1440 etc. Current Timeframe=0. 
extern ENUM_AUTOTF TimeFrame_Auto=NextTF;    /* Timeframe Auto Select */ // Automatically select higher TF. M15 and M30 -> H1. Off=0, 1st HTF=1, 2nd HTF=2
extern string    Stoch_Settings="——————————————————————————————"; /* Stochastic Settings */ 
extern ENUM_STOCHMODE Stoch_TapeMode=KoverD; /* Mode: %K over %D or Slope Up/Down */ // Mode: 0=Show K over D and overbought/oversold, 1=Show K Slope and overbought/oversold. 
extern int       Stoch_KPeriod=11;           /* %K Period */
extern int       Stoch_DPeriod=3;            /* %D Period */
extern int       Stoch_Slowing=3;            /* Slowing */
extern ENUM_STO_PRICE  Stoch_PriceField=STO_LOWHIGH;  /* Price Field */   // "<< 0=High/Low, 1=Close/Close >>";
extern ENUM_MA_METHOD  Stoch_MAMethod=MODE_SMA; /* MA Method */    // "<< SMA=0, EMA=1, SMMA=2, LWMA=3 >>";
extern int       Stoch_Low=20;               /* Low Level */
extern int       Stoch_High=80;              /* High Level */

// indicator buffers
double gadUp[];
double gadDn[];
double gadLine[];

// Globals
int giRepaintBars;
int giTimeFrame;
bool gbInit;


//+------------------------------------------------------------------+
int init() {
  IndicatorBuffers(3); 
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexBuffer(0,gadUp);
  SetIndexLabel(0,NULL);
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexBuffer(1,gadDn);
  SetIndexLabel(1,NULL);
  SetIndexStyle(2,DRAW_LINE);
  SetIndexBuffer(2,gadLine);
  SetIndexLabel(2,NULL);
  
  // Set Timeframe
  switch(TimeFrame_Auto) {
    case 1: 
      giTimeFrame=NextHigherTF(TimeFrame_Period); 
      giRepaintBars=giTimeFrame/Period()+2;
    break;
    case 2: 
      giTimeFrame=NextHigherTF(NextHigherTF(TimeFrame_Period));
      giRepaintBars=giTimeFrame/Period()+2;
    break;
    default: 
      if (TimeFrame_Period<1 || TimeFrame_Period==Period()) {
        giTimeFrame=Period();
        giRepaintBars=0;
      }
      else {
        giTimeFrame=TimeFrame_Period;
        giRepaintBars=TimeFrame_Period/Period()+2;
      }
    break;
  }
  if (Stoch_TapeMode==0)
    IndicatorShortName(TF2Str(giTimeFrame)+"-Stoch("+(string)Stoch_KPeriod+","+(string)Stoch_DPeriod+","+(string)Stoch_Slowing+") ");
  else
    IndicatorShortName(TF2Str(giTimeFrame)+"-Stoch("+(string)Stoch_KPeriod+","+(string)Stoch_Slowing+") ");
  gbInit=True;
  return(0);
}

//+------------------------------------------------------------------+
int deinit() {
   return (0);
}


//+------------------------------------------------------------------+
int start() {
  int i, j, iNewBars, iCountedBars;
  static int iDivider=-1;
  static int iHTFBar=-1;
  double dSig0, dSig1;
  int iPeriodSec=giTimeFrame*60;  
  static datetime tNextBar;
  
  if (gbInit) {
    tNextBar=Time[Bars-1]/iPeriodSec;
    tNextBar=tNextBar*iPeriodSec+iPeriodSec;
    gbInit=False;
  }
  
  // Get unprocessed bars
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1); 
  if(iCountedBars>0) iCountedBars--;
  
  // Set bars to redraw
  if (NewBars(giTimeFrame)>3)
    iNewBars=Bars-1;
  else
    iNewBars=Bars-iCountedBars;
  if (iNewBars<giRepaintBars)
    iNewBars=giRepaintBars;
  
  for(i=iNewBars; i>=0; i--) {
    if (i>Bars-Stoch_KPeriod) continue;
    // Shift index for higher time-frame
    if (giTimeFrame>Period() )
      j=iBarShift(Symbol(), giTimeFrame, Time[i]);
    else
      j=i;
    // Calc Stoch
    if (iHTFBar!=j) {
      iHTFBar=j;
      dSig0=iStochastic(Symbol(),giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_MAIN,j);
      if (Stoch_TapeMode==0)
        dSig1=iStochastic(Symbol(),giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_SIGNAL,j);
      else
        dSig1=iStochastic(Symbol(),giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_MAIN,j+1);
      
      if (giTimeFrame>Period() && gadLine[i]==EMPTY_VALUE) {
        iDivider *=-1;
      }  
    }
    
    if (giTimeFrame>Period() && gadLine[i]==EMPTY_VALUE)
        gadLine[i]=iDivider*DIVIDER_LINE;

    if (iClose(NULL,giTimeFrame,j)==0) {
      gadUp[i]=EMPTY_VALUE;
      gadDn[i]=EMPTY_VALUE;
    }  
    else if (dSig0>dSig1 && dSig0>Stoch_Low) {
      gadUp[i]=1;
      gadDn[i]=EMPTY_VALUE;
    }
    else if (dSig0<dSig1 && dSig0<Stoch_High) {
      gadUp[i]=EMPTY_VALUE;
      gadDn[i]=1;
    }  
    else if (dSig0>Stoch_High) {
      gadUp[i]=1;
      gadDn[i]=EMPTY_VALUE;
    }
    else if (dSig0<Stoch_Low) {
      gadUp[i]=EMPTY_VALUE;
      gadDn[i]=1;
    }
  }
  
  return(0);
}
//+------------------------------------------------------------------+


//-----------------------------------------------------------------------------
// function: NewBars()
// Description: Return nr of new bars on a TF
//-----------------------------------------------------------------------------
int NewBars(int iPeriod) {
  static int iPrevSize=0;
  int iNewSize;
  int iNewBars;
  datetime tTimeArray[];
  
  ArrayCopySeries(tTimeArray,MODE_TIME,Symbol(),iPeriod);
  iNewSize=ArraySize(tTimeArray);
  iNewBars=iNewSize-iPrevSize;
  iPrevSize=iNewSize;
  return(iNewBars);
}


//-----------------------------------------------------------------------------
// function: TF2Str()
// Description: Convert time-frame to a string
//-----------------------------------------------------------------------------
string TF2Str(int iPeriod) {
  switch(iPeriod) {
    case PERIOD_M1: return("M1");
    case PERIOD_M5: return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M30");
    case PERIOD_H1: return("H1");
    case PERIOD_H4: return("H4");
    case PERIOD_D1: return("D1");
    case PERIOD_W1: return("W1");
    case PERIOD_MN1: return("MN1");
    default: return("M"+(string)iPeriod);
  }
  return("M?");
}


//-----------------------------------------------------------------------------
// function: NextHigherTF()
// Description: Select the next higher time-frame. 
//              Note: M15 and M30 both select H1 as next higher TF. 
//-----------------------------------------------------------------------------
int NextHigherTF(int iPeriod) {
  if (iPeriod==0) iPeriod=Period();
  switch(iPeriod) {
    case PERIOD_M1: return(PERIOD_M5);
    case PERIOD_M5: return(PERIOD_M15);
    case PERIOD_M15: return(PERIOD_H1);
    case PERIOD_M30: return(PERIOD_H1);
    case PERIOD_H1: return(PERIOD_H4);
    case PERIOD_H4: return(PERIOD_D1);
    case PERIOD_D1: return(PERIOD_W1);
    case PERIOD_W1: return(PERIOD_MN1);
    case PERIOD_MN1: return(PERIOD_MN1);
    default: return(Period());
  }
  return(Period());
}