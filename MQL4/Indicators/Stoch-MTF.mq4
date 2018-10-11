/*------------------------------------------------------------------------------------
   Name: Stoch-MTF.mq4
   Copyright ©2012, Xaphod, http://www.xaphod.com
   
   Description: MTF Stochastic with linear interpoation between bars on the higher 
                timeframes. Features:
                - Linear interpolation of values between bars.
                - Dots can be used to tag the closing lower time-frame bar on the line.
                - Dual color to denote rising/over bought and Falling/oversold.

   Change log: 
       2014-02-17. v1.601
          - Fixed init error on terminal startup
       2014-02-14. v1.600
          - Update for MT4.5
       2012-07-16. Xaphod, v1.00 
          - First Release 
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "Copyright ©2012, xaphod.com"
#property link      "http://www.xaphod.com"
#property strict
#property version "1.601"
#property description "MTF Stochastic with linear interpoation between bars on the higher timeframes."
#property description ""
#property description "Features:"
#property description "  Linear interpolation of values between bars"
#property description "  Dots can be used to tag the closing lower time-frame bar on the line."
#property description "  Dual color to denote rising/over bought and Falling/oversold."

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 RoyalBlue
#property indicator_width1 2
#property indicator_color2 Red
#property indicator_width2 2
#property indicator_color3 Gold
#property indicator_width3 2

#property indicator_color4 MediumBlue
#property indicator_width4 0
#property indicator_color5 SkyBlue
#property indicator_width5 1
#property indicator_style5 STYLE_DOT
#property indicator_color6 LightSkyBlue
#property indicator_width6 1
#property indicator_style6 STYLE_DOT


#property indicator_level1 20
#property indicator_level2 50
#property indicator_level3 80
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor DimGray
#property indicator_minimum 0
#property indicator_maximum 100

enum ENUM_AUTOTF {
  Disabled=0,
  NextTF=1,
  NextNextTF=2
};

// Constant definitions
#define INDICATOR_NAME "Stoch"

// Indicator parameters
extern string    TimeFrame_Settings="——————————————————————————————"; /* Timeframe Settings */ 
extern ENUM_TIMEFRAMES    TimeFrame_Period=PERIOD_CURRENT;  /* Timeframe */ // Timeframe: M1,M5,M15,M30;H1,H4,D1,W1,MN1. OR 1,5,15,30,60,240,1440,10080,43200. Current Timeframe=0.
extern ENUM_AUTOTF TimeFrame_Auto=NextTF;          /* Timeframe Auto Select */ // Automatically select higher TF. M15 and M30 -> H1. Off=0, 1st HTF=1, 2nd HTF=2
extern string    Stoch_Settings="——————————————————————————————"; /* Stochastic Settings */ 
extern int       Stoch_KPeriod=11;          /* %K Period */ // %K line period
extern int       Stoch_DPeriod=3;           /* %D Period */ // %D line period
extern int       Stoch_Slowing=3;           /* Slowing */   // Slowing value
extern ENUM_STO_PRICE Stoch_PriceField=STO_LOWHIGH; /* Price Field */        // High/Low=0, Close/Close=1
extern ENUM_MA_METHOD Stoch_MAMethod=MODE_SMA; /* MA Method */ // SMA=0, EMA=1, SMMA=2, LWMA=3
extern int       Stoch_Low=20;              /* Low Level */ // Low level value
extern int       Stoch_High=80;             /* High Level */ // Hig level value
extern string    Show_Settings="——————————————————————————————"; /* Display Settings */ 
extern int       Show_MaxBars=0;            /* Show Max Bars (Set to 0 for full history) */ // Max bars to draw. Set to 0 to draw full chart history.
extern bool      Show_BarClose=True;        /* Draw Dot on Close Bars */ // Draw dot at stochastic value on the closing bar
extern bool      Show_2Color=True;          /* Dual Color %K Line */     // Use 2 colors. 1: Rising and/or above high level. 2: Falling and/or below low level
extern bool      Show_DPeriod=True;         /* Show %D Line */  // Draw line on stochastic value


// Global module varables
double gadStochKline[];
double gadStochKopen[];
double gadStochKdot[];
double gadStochDline[];
double gadStochDopen[];
double gadStochKDn[];

int giRepaintBars;
int giTimeFrame;
int giMinData;
bool gbDataError=False;


//-----------------------------------------------------------------------------
// function: init()
// Description: Custom indicator initialization function.
//-----------------------------------------------------------------------------
int init() {
  IndicatorDigits(1);
  // Set buffers
  SetIndexStyle(0, DRAW_LINE);
  SetIndexBuffer(0, gadStochKline);
  SetIndexLabel(0,"Stoch K line");
  SetIndexStyle(1, DRAW_LINE);
  SetIndexBuffer(1, gadStochKDn);
  SetIndexLabel(1,"Dn");
  SetIndexStyle(2, DRAW_LINE);
  SetIndexBuffer(2, gadStochKopen);
  SetIndexLabel(2,"Stoch K open");
  SetIndexStyle(3,DRAW_ARROW);
  SetIndexArrow(3,159);
  SetIndexBuffer(3, gadStochKdot);
  SetIndexLabel(3,NULL);

  
  SetIndexStyle(4, DRAW_LINE);
  SetIndexBuffer(4, gadStochDline);
  SetIndexLabel(4,"Stoch D line");
  SetIndexStyle(5, DRAW_LINE);
  SetIndexBuffer(5, gadStochDopen);
  SetIndexLabel(5,NULL);
  
  
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
      if (TimeFrame_Period==0 || TimeFrame_Period==Period()) {
        giTimeFrame=Period();
        giRepaintBars=0;
      }
      else {
        giTimeFrame=TimeFrame_Period;
        giRepaintBars=giTimeFrame/Period()+2;
      }
    break;
  }
  if (Show_MaxBars<1 || Show_MaxBars>(Bars-Stoch_KPeriod-10))
    Show_MaxBars=Bars-Stoch_KPeriod-10;
  Show_MaxBars=MathMin(Show_MaxBars,iBars(NULL,giTimeFrame)*giTimeFrame/Period());
  
  // Name & Stuff
  IndicatorShortName(TF2Str(giTimeFrame)+"-Stoch("+(string)Stoch_KPeriod+","+(string)Stoch_DPeriod+","+(string)Stoch_Slowing+") ");
  
  return(0);
}

//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit() {
   return (0);
}


///-----------------------------------------------------------------------------
// function: start()
// Description: Custom indicator iteration function.
//-----------------------------------------------------------------------------
int start() {
  int iNewBars;
  int iCountedBars; 
  int i,x0,x1;  
  int iHTF, iCTF;
  double y0,y1;
  
  //HiResTimer(0,TIMER_START); 
  // Get unprocessed ticks
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1); 
  if(iCountedBars>0) iCountedBars--;
  
  // Set bars to redraw
  if (NewBars(giTimeFrame)>3)
    iNewBars=Bars-1;
  else
    iNewBars=Bars-iCountedBars;
  iNewBars=MathMin(MathMax(iNewBars,giRepaintBars),Show_MaxBars);
  
  for(iCTF=iNewBars; iCTF>=0; iCTF--) {
    if (iCTF>Bars-Stoch_KPeriod) 
      continue;
    // get higher time-frame bar index for the current bar 
    if (giTimeFrame>Period())
      iHTF=iBarShift(NULL, giTimeFrame, Time[iCTF]);
    else
      iHTF=iCTF;
        
    // On new higher time-frame bar interpolate between the close prices of the previous two bars
    if (Time[iCTF+1]<iTime(NULL, giTimeFrame, iHTF)) {
      // Plot dot on close price
      if (Show_BarClose)
        gadStochKdot[iCTF+1]=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_MAIN,iHTF+1); 
      else
        gadStochKdot[iCTF+1]=EMPTY_VALUE;
      
      // Get the indexes for the current and previous bar close times
      x1=iCTF+1;
      x0=x1+1;
      while(Time[x0]>=iTime(NULL, giTimeFrame, iHTF+1) && x0<Show_MaxBars)
        x0++;

      //Interpolate stoch K line between the close values
      y0=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_MAIN,iBarShift(NULL, giTimeFrame, Time[x0]));
      y1=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_MAIN,iBarShift(NULL, giTimeFrame, Time[x1]));
      for (i=x0; i>=x1; i--) {
        gadStochKline[i]=Interpolate(i,x0,x1,y0,y1);
        gadStochKopen[i]=EMPTY_VALUE;
        if (Show_2Color) {
          if ((gadStochKline[i]<gadStochKline[i+1] && gadStochKline[i]<Stoch_High) || gadStochKline[i]<Stoch_Low) {
            gadStochKDn[i]=gadStochKline[i];
            if (gadStochKDn[i+1]==EMPTY_VALUE && gadStochKline[i+1]<Stoch_High)
            gadStochKDn[i+1]=gadStochKline[i+1];
          }
          else {
            gadStochKDn[i]=EMPTY_VALUE;
          }
        }  
      }
      if (Show_DPeriod) {
        //Interpolate stoch D line between the close values
        y0=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_SIGNAL,iBarShift(NULL, giTimeFrame, Time[x0]));
        y1=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_SIGNAL,iBarShift(NULL, giTimeFrame, Time[x1]));
        for (i=x0; i>=x1; i--) {
          gadStochDline[i]=Interpolate(i,x0,x1,y0,y1);
          gadStochDopen[i]=EMPTY_VALUE;
        }
      }
    }
    else {
      gadStochKdot[iCTF+1]=EMPTY_VALUE; 
    }
  }  
  
  // Draw open bar stoch
  // Get interval for current bar
  x1=0;
  x0=x1+1;
  while(Time[x0]>=iTime(NULL, giTimeFrame, 0) && x0<Show_MaxBars)
    x0++;
  // Calc stoch for the close prices
  y0=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_MAIN,1);
  y1=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_MAIN,0);
  // Interpolate between the close prices
  for (i=x0; i>=x1; i--) {
    gadStochKopen[i]=Interpolate(i,x0,x1,y0,y1);
    if (i!=x0) {
      gadStochKline[i]=EMPTY_VALUE;
      gadStochKDn[i]=EMPTY_VALUE;
    }
  }
  if (Show_DPeriod) {
    y0=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_SIGNAL,1);
    y1=iStochastic(NULL,giTimeFrame,Stoch_KPeriod,Stoch_DPeriod,Stoch_Slowing,Stoch_MAMethod,Stoch_PriceField,MODE_SIGNAL,0);
    for (i=x0; i>=x1; i--) {
      gadStochDopen[i]=Interpolate(i,x0,x1,y0,y1);
      if (i!=x0) {
        gadStochDline[i]=EMPTY_VALUE;
      }  
    }
  } 
  
  return(0);
}
//+------------------------------------------------------------------+

//-----------------------------------------------------------------------------
// function: Interpolate()
// Description: Linear interpolation between two points
//-----------------------------------------------------------------------------
double Interpolate(int x, int x0, int x1, double y0, double y1 ){
  double k;
  
  // Invalid interval  
  if (x0==x1)
    return(EMPTY_VALUE);
  
  // Equation of a straight line  
  // y=kx+m, k=(y1-y0)/(x1-x0)    
  k=(y1-y0)/(x1-x0);
  x=x-x0;
  return(k*x+y0);
}  


//-----------------------------------------------------------------------------
// function: NewBars()
// Description: Return nr of new bars on a TF
//-----------------------------------------------------------------------------
int NewBars(int iPeriod) {
  static int iPrevSize=0;
  int iNewSize=0;
  int iNewBars=0;
  datetime tTimeArray[];
  
  if (ArrayCopySeries(tTimeArray,MODE_TIME,Symbol(),iPeriod)>0) {
    iNewSize=ArraySize(tTimeArray);
    iNewBars=iNewSize-iPrevSize;
    iPrevSize=iNewSize;
  }
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
}

