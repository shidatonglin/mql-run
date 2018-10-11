/*------------------------------------------------------------------------------------
   Name: GMTS-Tape.mq4
   
   Description: Non-repainting Tape chart of the GMTS-Matrix for the Genesis Matrix 
                Trading System.
                Consists of thefollowing indicators:
                1. TVI
                2. CCI
                3. Gann High/Low Activator
                4. T3 Moving Average
	Note:
	   Requires that the following indicators are installed and working:
	   TVI.mq4, GannHiLo-Histo.mq4, T3MA-Basic.mq4       
	          
   Change log:
       2014-02-10. Xaphod, v1.600
          - Update to mql4.5/MT4.5
          - Removed check for custom indicators. There is no way to find the exact path of the indicators.
       2012-09-08. Xaphod, v1.02
          - Draw period divider lines between the bars.  
       2012-09-07. Xaphod, v1.01
          - Added period divider lines.   
       2012-09-04. Xaphod, v1.00
          - Based on STSn Tape v1.02
          - Switched location of the T3 and GHL to make layout the same as the 
            official genesis matrix
          - Added MaxBars parameter to T3 to reduce load time. Set to 0 for full history  
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "Copyright © 2012, Xaphod"
#property link      "http://www.xaphod.com"

//#property strict
#property version    "1.600"

#property description "Tape Chart of the Genesis Matrix Indicator."
#property description "The matrix consists of the following indicators: TVI, CCI, GannHiLo Activator, T3 Moving Average."
#property description " "
#property description "Requirements: The following indicators must installed and working:"
#property description "    TVI.mq4, GannHiLo-Histo.mq4, T3MA-Basic.mq4"
#property description " "
#property description "Troubleshooting: Check the 'Journal' and 'Expert' tabs in the terminal window for errors."
#property description "Misc: To use the 'Alert_Sound' together with the 'Alert_Popup', disable the alert sound in the "
#property description "        'Tools/Options/Events' Tab."

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 RoyalBlue
#property indicator_color4 FireBrick
#property indicator_width1  4
#property indicator_width2  4
#property indicator_width3  4
#property indicator_width4  4
#property indicator_maximum 1
#property indicator_minimum 0

//#include <xPrint.mqh>

// Constant definitions
#define INDICATOR_NAME "GMTS"
#define INDICATOR_VERSION "1.600"

#define IND_TVI        "TVI"
#define IND_GANNHILO   "GannHiLo-Histo"
#define IND_T3MA       "T3MA-Basic"

enum ENUM_NEXTTF {
  Disabled=0,
  NextTF=1,
  NextNextTF=2
};

// Indicator parameters
extern string    TimeFrame_Settings="——————————————————————————————";
extern ENUM_TIMEFRAMES TimeFrame_Period=PERIOD_CURRENT;    // Timeframe: 0,1,5,15,30,60,240,1440 etc. Current Timeframe=0. 
extern ENUM_NEXTTF  TimeFrame_AutoSelect=Disabled;           // Automatically select higher TF. M15 and M30 -> H1. Off=0, 1st HTF=1, 2nd HTF=2
extern string    Mode_Settings="——————————————————————————————";
extern bool      Mode_Show3Bars=False;       // Indicate when 3 of 4 bars are the same
extern color     Mode_NoSigColor=clrDimGray;    // Color of no signal bar for 4 bars mode 
extern color     Mode_3UpColor=clrRoyalBlue;    // Color of up signal bar for 3 of 4 bars 
extern color     Mode_3DownColor=clrFireBrick;  // Color of down signal bar for 3 of 4 bars
extern string    TVI_Settings="——————————————————————————————";
extern int       TVI_r=12;
extern int       TVI_s=12;
extern int       TVI_u=5;
extern string    CCI_Settings="——————————————————————————————";
extern int       CCI_Period=20;
extern string    T3MA_Settings="——————————————————————————————";
extern int       T3MA_Period=8;
extern double    T3MA_b=0.618;
extern int       T3MA_MaxBars=5000;           // Set MaxBars to 0 to show the full history
extern string    T3MA_Label="T3 "; 
extern string    GannHiLo_Settings="——————————————————————————————";
extern int       GannHiLo_Period=10;
extern string    Alert_Settings="——————————————————————————————";
extern bool      Alert_3Bars=False;          // Alert when 3 bars line up
extern bool      Alert_4Bars=False;          // Alert when 4 bars line up
extern bool      Alert_OnBarClose=True;      // Alert only when an open bar closes
extern bool      Alert_Popup=True;           // Enable popup window & sound on alert
extern string    Alert_Sound="";             // Play sound on Alert_ Wav files only
extern bool      Alert_Email=False;          // Enable send email on alert
extern string    Alert_Subject="";           // Email subject. Null string ("") will result in a preconfigured subject.
extern string    Divider_Settings="——————————————————————————————";
extern int       Divider_MaxLines=30;        // Draw period divider line for higher time-frame bars. Nr of bars back. Set to 0 to disable.
extern color     Divider_Color=clrDarkGray;     // Color of period divider lines

// Global module varables
// Histogram
double gadSigUp[];
double gadSigDn[];
double gadSigUpR[];
double gadSigDnR[];

double gadTVI[];
double gadCCI[];
double gadT3MA[];
double gadGHL[];

// Globals
int giRepaintBars;
int giTimeFrame;
string gsIndicatorName;
bool gbInit;

//-----------------------------------------------------------------------------
// function: init()
// Description: Custom indicator initialization function.
//-----------------------------------------------------------------------------
int init() {
  // Init indicator buffers
  IndicatorBuffers(8);
  // Tape Chart
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexBuffer(0,gadSigUp);
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexBuffer(1,gadSigDn);
  if (Mode_Show3Bars)
    SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,EMPTY,Mode_3UpColor);
  else
    SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,EMPTY,Mode_NoSigColor);
  SetIndexBuffer(2,gadSigUpR);
  SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,EMPTY,Mode_3DownColor);
  SetIndexBuffer(3,gadSigDnR);
  // Indicator data
  SetIndexStyle(4,DRAW_NONE);
  SetIndexBuffer(4,gadTVI);
  SetIndexStyle(5,DRAW_NONE);
  SetIndexBuffer(5,gadCCI);
  SetIndexStyle(6,DRAW_NONE);
  SetIndexBuffer(6,gadT3MA);  
  SetIndexStyle(7,DRAW_NONE);
  SetIndexBuffer(7,gadGHL);
  // Null Label
  for (int i=0; i<8; i++) {
    SetIndexLabel(i,NULL);
    SetIndexEmptyValue(i,0.0);
  }
  
  // Set Timeframe
  switch(TimeFrame_AutoSelect) {
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
        giTimeFrame=(ENUM_TIMEFRAMES)Period();
        giRepaintBars=0;
      }
      else {
        giTimeFrame=TimeFrame_Period;
        giRepaintBars=TimeFrame_Period/(ENUM_TIMEFRAMES)Period()+2;
      }
    break;
  }
    
  // Misc
  gsIndicatorName=INDICATOR_NAME+"-Tape ("+TF2Str(TimeFrame_Period)+")";
  IndicatorShortName(gsIndicatorName);
  gbInit=True;
  return(0);
}


//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit() {
  // Clear text objects
  for(int i=ObjectsTotal()-1; i>-1; i--)
    if (StringFind(ObjectName(i),gsIndicatorName)>=0)  ObjectDelete(ObjectName(i));
  return (0);
}


//-----------------------------------------------------------------------------
// function: start()
// Description: Custom indicator iteration function.
//-----------------------------------------------------------------------------
int start() {
  int i, j, iNewBars, iCountedBars;
  static datetime tCurBar=0;
  
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
  
  // Calc Data
  ProcessTVI(iNewBars, giTimeFrame, TVI_r, TVI_s, TVI_u, gadTVI);
  ProcessCCI(iNewBars, giTimeFrame, CCI_Period, gadCCI);
  ProcessGannHiLo(iNewBars, giTimeFrame, GannHiLo_Period, gadGHL);
  ProcessT3MA(iNewBars, giTimeFrame, T3MA_Period, T3MA_b, gadT3MA);
  
  //Update Tape Chart
  for (i=iNewBars+giTimeFrame/Period();i>=0;i--) {
    if (i>=Bars)
      continue;
    if (UpSignal(i)==4) {
      gadSigUp[i]=1;
      gadSigDn[i]=0;
      gadSigUpR[i]=0;
      gadSigDnR[i]=0;
    }
    else if (DnSignal(i)==4) {
      gadSigUp[i]=0;
      gadSigDn[i]=1;
      gadSigUpR[i]=0;
      gadSigDnR[i]=0;
    }
    else if (UpSignal(i)==3 && Mode_Show3Bars) {
      gadSigUp[i]=0;
      gadSigDn[i]=0;
      gadSigUpR[i]=1;
      gadSigDnR[i]=0;
    }
    else if (DnSignal(i)==3 && Mode_Show3Bars) {
      gadSigUp[i]=0;
      gadSigDn[i]=0;
      gadSigUpR[i]=0;
      gadSigDnR[i]=1;
    }
    else if (!Mode_Show3Bars) {
      gadSigUp[i]=0;
      gadSigDn[i]=0;
      gadSigUpR[i]=1;
      gadSigDnR[i]=0;
    }
    else {
      gadSigUp[i]=0;
      gadSigDn[i]=0;
      gadSigUpR[i]=0;
      gadSigDnR[i]=0;
    }
  }
  
  // Alerts
  if (Alert_4Bars)
    CheckAlert4(giTimeFrame);
  if (Alert_3Bars)
    CheckAlert3(giTimeFrame);  

  // Tasks to execute on bar close
  if (tCurBar<Time[0]) {
    tCurBar=Time[0];
    
    
    if (Divider_MaxLines>0 && giTimeFrame>Period()) {
      i=0;
      j=0;
      while(i<Divider_MaxLines) {
        if (iBarShift(Symbol(), giTimeFrame, Time[j]) != iBarShift(Symbol(), giTimeFrame, Time[j+1])) {
          DrawDividerLine(j,i,STYLE_SOLID,1,Divider_Color);
          i++;
        }
        j++;
      } 
    }      
    // Clear the init flag   
    if (gbInit) 
      gbInit=False;
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
// function: ProcessTVI()
// Description: Calc TVI data and update matrix
//-----------------------------------------------------------------------------
int ProcessTVI(int iNewBars, int iTF, int r, int s, int u, double& vdSig[]) {
  int i,j;
  double dTVI0, dTVI1;
  int iHTFBar=-1;
  
  for (i=iNewBars;i>=0;i--) {
    if (i>MathMax(Bars-2,Bars-r))
      continue;
    // Get index for higher timeframe bar
    if (iTF>Period())
      j=iBarShift(Symbol(), iTF, Time[i]);
    else
      j=i;
    // Calc TVI  
    if (iHTFBar!=j) {
      iHTFBar=j;
      dTVI1=iCustom(Symbol(),iTF,IND_TVI,r,s,u,0,j+1);
      dTVI0=iCustom(Symbol(),iTF,IND_TVI,r,s,u,0,j);
    }
    // Set TVI status
    if (dTVI0==EMPTY_VALUE || dTVI1==EMPTY_VALUE)
      vdSig[i]=0;
    else if (dTVI0>=dTVI1)
      vdSig[i]=1;
    else  
      vdSig[i]=-1; 
  }
  return(0);
}


//-----------------------------------------------------------------------------
// function: ProcessCCI()
// Description: Calc CCI data and update matrix
//-----------------------------------------------------------------------------
int ProcessCCI(int iNewBars, int iTF, int iPeriod, double& vdSig[]) {
  int i,j;
  double dSig;
  int iHTFBar=-1;
  
  for(i=iNewBars; i>=0; i--) {
    if (i>MathMax(Bars-2,Bars-iPeriod))
      continue;
    // Shift index for higher time-frame
    if (iTF>Period() )
      j=iBarShift(Symbol(), iTF, Time[i]);
    else
      j=i;
    // Calc CCI
    if (iHTFBar!=j) {
      iHTFBar=j;
      dSig=iCCI(NULL, iTF, iPeriod, PRICE_TYPICAL, j);
    }
    // Set CCI status
    if (iClose(NULL,iTF,i)==0)
      vdSig[i]=0;
    else if (dSig>=0) 
      vdSig[i]=1;
    else  
      vdSig[i]=-1;
  }
  return(0);
}


//-----------------------------------------------------------------------------
// function: ProcessGannHiLo()
// Description: Calc GannHiLo data and update matrix
//-----------------------------------------------------------------------------
int ProcessGannHiLo(int iNewBars, int iTF, int iPeriod, double& vdSig[]) {
  int i,j,iUp;
  int iHTFBar=-1;
    
  for(i=iNewBars+iTF/Period(); i>=0; i--) {
    if (i>MathMax(Bars-2,Bars-iPeriod))
      continue;
    // Shift index for higher time-frame
    if (iTF>Period())
      j=iBarShift(Symbol(), iTF, Time[i]);
    else
      j=i;
    // Calc GannHiLo data
    if (iHTFBar!=j) {
      iHTFBar=j;
      iUp=(int)iCustom(NULL,iTF,IND_GANNHILO,GannHiLo_Period,0,j);
    }
    // Set Gann HiLo status
    if (iUp==EMPTY_VALUE)
      vdSig[i]=0;
    else if (iUp==1)
      vdSig[i]=1;
    else  
      vdSig[i]=-1;
  }
  return(0);
}


//-----------------------------------------------------------------------------
// function: ProcessGannHiLo()
// Description: Calc GannHiLo data and update matrix
//-----------------------------------------------------------------------------
int ProcessT3MA(int iNewBars, int iTF, int iPeriod, double db, double& vdSig[]) {
  int i,j;
  double dSig0,dSig1;
  int iHTFBar=-1;
  
  if (iNewBars>T3MA_MaxBars && T3MA_MaxBars>iPeriod) 
    iNewBars=T3MA_MaxBars;
    
  // Draw tape chart
  for(i=iNewBars+iTF/Period(); i>=0; i--) {
    if (i>MathMax(Bars-3,Bars-iPeriod))
      continue;
    // Shift index for higher time-frame
    if (iTF>Period())
      j=iBarShift(Symbol(), iTF, Time[i]);
    else
      j=i;
    // Calc T3MA
    if (iHTFBar!=j) {
      iHTFBar=j;
      dSig0 = iCustom(NULL,iTF,IND_T3MA,iPeriod,db,T3MA_MaxBars,0,j);
      dSig1 = iCustom(NULL,iTF,IND_T3MA,iPeriod,db,T3MA_MaxBars,0,j+1);
    }
    
    if (iClose(NULL,iTF,j)==0) 
      vdSig[i]=EMPTY_VALUE;  // No Data    
    else if (dSig0>=dSig1) 
      vdSig[i]=1;            // Bull signal
    else          
      vdSig[i]=-1;           // Bear signal
  }
  return(0);
} 


//-----------------------------------------------------------------------------
// function: CheckAlert()
// Description: Check for new alerts
//-----------------------------------------------------------------------------
void CheckAlert4(int iTF) {
  static datetime tAlertBar;
  static int iPrevAlert=0;
  
  if (Alert_Popup || Alert_Email || Alert_Sound!="") {
    
    // Alert on the close of the current bar
    if ((Alert_OnBarClose || gbInit) && tAlertBar<Time[iBarShift(Symbol(), iTF, Time[0])]) {
      
      tAlertBar=Time[iBarShift(Symbol(), iTF, Time[0])];
      // Clear alert flag
      if (iPrevAlert==1 && gadSigUp[1]!=1)
         iPrevAlert=0;
      else if (iPrevAlert==-1 && gadSigDn[1]!=1)
         iPrevAlert=0;
      // Alert and set alert flag
      if (gadSigUp[1]==1 && iPrevAlert!=1) {
         AlertNow(Symbol()+", "+TF2Str(Period())+": GMTS-Tape(4/4) Buy Signal.");
         iPrevAlert=1;
      }  
      else if (gadSigDn[1]==1 && iPrevAlert!=-1) {
         AlertNow(Symbol()+", "+TF2Str(Period())+": GMTS-Tape(4/4) Sell Signal.");
         iPrevAlert=-1;
      }
    }
  
    // Alert while the current bar is open
    if (!Alert_OnBarClose && tAlertBar<Time[iBarShift(Symbol(), iTF, Time[0])]) {
      // Clear alert flag
      if (iPrevAlert==1 && gadSigUp[0]!=1)
         iPrevAlert=0;
      else if (iPrevAlert==-1 && gadSigDn[0]!=1)
         iPrevAlert=0;      
      // Alert and set alert flag
      if (gadSigUp[0]==1 && iPrevAlert!=1) {
         AlertNow(Symbol()+", "+TF2Str(Period())+": GMTS-Tape(4/4) Buy Signal.");
         iPrevAlert=1;
         tAlertBar=Time[iBarShift(Symbol(), iTF, Time[0])];
      }  
      else if (gadSigDn[0]==1 && iPrevAlert!=-1) {
         AlertNow(Symbol()+", "+TF2Str(Period())+": GMTS-Tape(4/4) Sell Signal.");
         iPrevAlert=-1;
         tAlertBar=Time[iBarShift(Symbol(), iTF, Time[0])];
      }
    }
  }
  return;
}


//-----------------------------------------------------------------------------
// function: CheckAlert()
// Description: Check for new alerts
//-----------------------------------------------------------------------------
void CheckAlert3(int iTF) {
  static datetime tAlertBar;
  static int iPrevAlert=0;
  
  if (Alert_Popup || Alert_Email || Alert_Sound!="") {
    
    // Alert on the close of the current bar
    if ((Alert_OnBarClose || gbInit) && tAlertBar<Time[iBarShift(Symbol(), iTF, Time[0])]) {
      
      tAlertBar=Time[iBarShift(Symbol(), iTF, Time[0])];
      // Clear alert flag
      if (iPrevAlert==1 && gadSigUpR[1]!=1)
         iPrevAlert=0;
      else if (iPrevAlert==-1 && gadSigDnR[1]!=1)
         iPrevAlert=0;
      // Alert and set alert flag
      if (gadSigUpR[1]==1 && gadSigUp[1]!=1 && iPrevAlert!=1) {
         AlertNow(Symbol()+", "+TF2Str(Period())+": GMTS-Tape(3/4) Buy Signal.");
         iPrevAlert=1;
      }  
      else if (gadSigDnR[1]==1 && gadSigDn[1]!=1 && iPrevAlert!=-1) {
         AlertNow(Symbol()+", "+TF2Str(Period())+": GMTS-Tape(3/4) Sell Signal.");
         iPrevAlert=-1;
      }
    }
  
    // Alert while the current bar is open
    if (!Alert_OnBarClose && tAlertBar<Time[iBarShift(Symbol(), iTF, Time[0])]) {
      // Clear alert flag
      if (iPrevAlert==1 && gadSigUpR[0]!=1)
         iPrevAlert=0;
      else if (iPrevAlert==-1 && gadSigDnR[0]!=1)
         iPrevAlert=0;      
      // Alert and set alert flag
      if (gadSigUpR[0]==1 && gadSigUp[0]!=1 && iPrevAlert!=1) {
         AlertNow(Symbol()+", "+TF2Str(Period())+": GMTS-Tape(3/4) Buy Signal.");
         iPrevAlert=1;
         tAlertBar=Time[iBarShift(Symbol(), iTF, Time[0])];
      }  
      else if (gadSigDnR[0]==1 && gadSigDn[0]!=1 && iPrevAlert!=-1) {
         AlertNow(Symbol()+", "+TF2Str(Period())+": GMTS-Tape (3/4) Sell Signal.");
         iPrevAlert=-1;
         tAlertBar=Time[iBarShift(Symbol(), iTF, Time[0])];
      }
    }
  }
  return;
}


//-----------------------------------------------------------------------------
// function: AlertNow()
// Description: Signal the popup and email alerts
//-----------------------------------------------------------------------------
void AlertNow(string sAlertMsg) {
  
  if (gbInit)
    return;
  //Popup Alert 
  if (Alert_Popup) 
    Alert(INDICATOR_NAME,", ", sAlertMsg);      
  if (Alert_Sound!="")
    PlaySound(Alert_Sound);  
  //Email Alert
  if (Alert_Email) {
    if (Alert_Subject=="")
      SendMail( sAlertMsg, "MT4 Alert!\n"+INDICATOR_NAME+"\n" + TimeToStr(Time[0],TIME_DATE|TIME_SECONDS )+"\n"+sAlertMsg);
    else 
      SendMail( Alert_Subject, "MT4 Alert!\n"+INDICATOR_NAME+"\n" + TimeToStr(Time[0],TIME_DATE|TIME_SECONDS )+"\n"+sAlertMsg);          
  }
  return;
}


//-----------------------------------------------------------------------------
// function: UpSignal()
// Description: Return nr of up signals 
//-----------------------------------------------------------------------------
int UpSignal(int n) {
  int j=0;
  if (n<Bars) {
    if (gadTVI[n]==1) j++; 
    if (gadCCI[n]==1) j++;
    if (gadT3MA[n]==1) j++;
    if (gadGHL[n]==1) j++;
  }
  return(j);
}


//-----------------------------------------------------------------------------
// function: DnSignal()
// Description: Return nr of down signals 
//-----------------------------------------------------------------------------
int DnSignal(int n) {
  int j=0;
  
  if (n<Bars) {
    if (gadTVI[n]==-1) j++; 
    if (gadCCI[n]==-1) j++;
    if (gadT3MA[n]==-1) j++;
    if (gadGHL[n]==-1) j++;
  }
  return(j);
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
ENUM_TIMEFRAMES NextHigherTF(int iPeriod) {
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
    default: return((ENUM_TIMEFRAMES)Period());
  }
  return((ENUM_TIMEFRAMES)Period());
}


//-----------------------------------------------------------------------------
// function: DrawLine()
// Description: Draw a horizontal line at specific price
//----------------------------------------------------------------------------- 
int DrawDividerLine(int iBar, int iLineNr, int iLineStyle=STYLE_SOLID, int iLineWidth=1, color cLineColor=White) {
  string sLineId;
  
  // Set Line object ID  
  sLineId=gsIndicatorName+"_Divider_"+(string)iLineNr;
  
  // Draw line
  if (ObjectFind(sLineId)<0 ) {
    ObjectCreate(sLineId, OBJ_TREND, WindowFind(gsIndicatorName), Time[iBar], -90, Time[iBar+1], 80); 
    ObjectSet(sLineId, OBJPROP_STYLE, iLineStyle);     
    ObjectSet(sLineId, OBJPROP_WIDTH, iLineWidth);
    ObjectSet(sLineId, OBJPROP_BACK, False);
    ObjectSet(sLineId, OBJPROP_COLOR, cLineColor);
    ObjectSet(sLineId, OBJPROP_RAY, False);
  }  
  ObjectSet(sLineId, OBJPROP_TIME1, Time[iBar]);
  ObjectSet(sLineId, OBJPROP_TIME2, Time[iBar+1]);
  return(0);
}