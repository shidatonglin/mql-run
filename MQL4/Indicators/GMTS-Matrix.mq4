/*------------------------------------------------------------------------------------
   Name: GMTS-Matrix.mq4
   
   Description: Matrix indicator for the Genesis Matrix Trading System:
                Consists of the following indicators:
                1. TVI
                2. CCI
                3. Gann High/Low Activator
                4. T3 Moving Average
	Note:
	   Requires that the following indicators are installed and working:
	   TVI_mq4, GannHiLo-Histo.mq4, T3MA-Basic.mq4       
   
   Change log:
       2014-02-10. Xaphod, v1.600
          - Update to mql4.5 / MT4.5
          - Removed check for custom indicators. There is no way to find the exact path 
            of the indicators as they can be in sub-folders in the indicators folder.
       2012-09-08. Xaphod, v1.02
          - Draw period divider lines between the bars.  
       2012-09-07. Xaphod, v1.01
          - Added period divider lines.
       2012-09-04. Xaphod, v1.00
          - Based on STSn Matrix v1.02
          - Switched location of the T3 and GHL to make layout the same as the 
            official genesis version
          - Added MaxBars parameter to T3 to reduce load time. Set to 0 for full history  
-------------------------------------------------------------------------------------*/
// Indicator properties
#property copyright "Copyright © 2012, Xaphod"
#property link      "http://www.xaphod.com"

//#property strict
#property version    "1.600"

#property description "Genesis Matrix Indicator for the Genesis Matrix Trading System."
#property description "The matrix consists of the following indicators: TVI, CCI, GannHiLo Activator, T3 Moving Average."
#property description " "
#property description "Requirements: The following indicators must installed and working:"
#property description "    TVI.mq4, GannHiLo-Histo.mq4, T3MA-Basic.mq4"
#property description " "
#property description "Troubleshooting: Check the 'Journal' and 'Expert' tabs in the terminal window for errors."
#property description "Misc: To use the 'Alert_Sound' together with the 'Alert_Popup', disable the alert sound in the"
#property description "        'Tools/Options/Events' Tab."


#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 DodgerBlue
#property indicator_color4 Red
#property indicator_color5 DodgerBlue
#property indicator_color6 Red
#property indicator_color7 DodgerBlue
#property indicator_color8 Red
#property indicator_minimum 0
#property indicator_maximum 2.1

//#include <xPrint.mqh>

// Constant definitions
#define INDICATOR_NAME "GMTS"
#define INDICATOR_VERSION "1.600"
#define MATRIX_CHAR 110

#define IND_TVI        "TVI"
#define IND_GANNHILO   "GannHiLo-Histo"
#define IND_T3MA       "T3MA-Basic"

#define IDX_R1 0  // TVI
#define IDX_R2 1  // CCI
#define IDX_R3 2  // Gann
#define IDX_R4 3  // T3 MA


enum ENUM_NEXTTF {
  Disabled=0,
  NextTF=1,
  NextNextTF=2
};
 
// Indicator parameters
extern string    Indi_Version=INDICATOR_VERSION;
extern string    TimeFrame_Settings="——————————————————————————————";
extern ENUM_TIMEFRAMES TimeFrame_Period=PERIOD_CURRENT;        // Timeframe: 0,1,5,15,30,60,240,1440 etc. Current Timeframe=0. 
extern ENUM_NEXTTF  TimeFrame_AutoSelect=Disabled;          // Automatically select higher TF. M15 and M30 -> H1. Off=0, 1st HTF=1, 2nd HTF=2
extern string    TVI_Settings="——————————————————————————————";
extern int       TVI_r=12;
extern int       TVI_s=12;
extern int       TVI_u=5;
extern string    TVI_Label="TVI";
extern string    CCI_Settings="——————————————————————————————";
extern int       CCI_Period=20;
extern string    CCI_Label="CCI";
extern string    T3MA_Settings="——————————————————————————————";
extern int       T3MA_Period=8;
extern double    T3MA_b=0.618;
extern int       T3MA_MaxBars=5000;          // Set MaxBars to 0 to show the full history
extern string    T3MA_Label="T3 ";
extern string    GannHiLo_Settings="——————————————————————————————";
extern int       GannHiLo_Period=10;
extern string    GannHiLo_Label="GHL";
extern string    Alert_Settings="——————————————————————————————";
extern bool      Alert_OnBarClose=True;     // Alert only when an open bar closes
extern bool      Alert_Popup=False;         // Enable popup window & sound on alert
extern string    Alert_Sound="";            // Play sound on Alert_ Wav files only
extern bool      Alert_Email=False;         // Enable send email on alert
extern string    Alert_Subject="";          // Email Subject. Null string ("") will result in a preconfigured subject.
extern string    Label_Settings="——————————————————————————————";
extern color     Label_Color=White;         // Color of Histogram Id labels
extern string    Divider_Settings="——————————————————————————————";
extern int       Divider_MaxLines=30;       // Draw period divider line for higher time-frame bars. Nr of bars back. Set to 0 to disable.
extern color     Divider_Color=DarkGray;    // Color of period divider lines


// Global module varables
// Histogram
double gadR1Up[];
double gadR1Dn[];
double gadR2Up[];
double gadR2Dn[];
double gadR3Up[];
double gadR3Dn[];
double gadR4Up[];
double gadR4Dn[];

// Labels
double gadGap[4];

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
  SetIndexStyle(0,DRAW_ARROW);
  SetIndexBuffer(0,gadR1Up);
  SetIndexStyle(1,DRAW_ARROW);
  SetIndexBuffer(1,gadR1Dn);
  SetIndexStyle(2,DRAW_ARROW);
  SetIndexBuffer(2,gadR2Up);
  SetIndexStyle(3,DRAW_ARROW);
  SetIndexBuffer(3,gadR2Dn);  
  SetIndexStyle(4,DRAW_ARROW);
  SetIndexBuffer(4,gadR3Up);
  SetIndexStyle(5,DRAW_ARROW);
  SetIndexBuffer(5,gadR3Dn);
  SetIndexStyle(6,DRAW_ARROW);
  SetIndexBuffer(6,gadR4Up);
  SetIndexStyle(7,DRAW_ARROW);
  SetIndexBuffer(7,gadR4Dn);
  for (int i = 0; i < 8; i++) {
    SetIndexLabel(i,NULL);
    SetIndexEmptyValue(i,0.0);
    SetIndexArrow(i,MATRIX_CHAR);
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
        giTimeFrame=Period();
        giRepaintBars=0;
      }
      else {
        giTimeFrame=TimeFrame_Period;
        giRepaintBars=TimeFrame_Period/Period()+2;
      }
    break;
  }
  
  // Set histogram positions
  gadGap[IDX_R1]=1.9;
  gadGap[IDX_R2]=1.4;
  gadGap[IDX_R3]=0.9;
  gadGap[IDX_R4]=0.4;
    
  // Misc
  gsIndicatorName=INDICATOR_NAME+"-Matrix ("+TF2Str(giTimeFrame)+")";
  IndicatorShortName(gsIndicatorName);
  gbInit=True;
  return(INIT_SUCCEEDED);
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
  static datetime tCurBar;
  
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

  // Calc indicator data and update matrix
  ProcessTVI(iNewBars, giTimeFrame, TVI_r, TVI_s, TVI_u, gadR1Up, gadR1Dn,IDX_R1);
  ProcessCCI(iNewBars, giTimeFrame, CCI_Period, gadR2Up, gadR2Dn,IDX_R2);
  ProcessT3MA(iNewBars, giTimeFrame, T3MA_Period, T3MA_b, T3MA_MaxBars, gadR4Up, gadR4Dn,IDX_R3);
  ProcessGannHiLo(iNewBars, giTimeFrame, GannHiLo_Period, gadR3Up, gadR3Dn,IDX_R4);
  
  // Alerts
  CheckAlert(giTimeFrame);
    
  // Tasks to execute on bar close
  if (tCurBar<Time[0]) {
    tCurBar=Time[0];
    
    // Write/Update bar labels
    Writelabel(TVI_Label,gadGap[IDX_R1]+0.2);
    Writelabel(CCI_Label,gadGap[IDX_R2]+0.2);
    Writelabel(T3MA_Label,gadGap[IDX_R3]+0.2);
    Writelabel(GannHiLo_Label,gadGap[IDX_R4]+0.2);
    
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
int ProcessTVI(int iNewBars, int iTF, int r, int s, int u, double& vdUp[], double& vdDn[], int iRow) {
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
    // No data
    if (dTVI0==EMPTY_VALUE) {
      vdUp[i]=0;
      vdDn[i]=0;
    }
    // Bull signal
    if (dTVI0>=dTVI1) {
      vdUp[i]=gadGap[iRow];
      vdDn[i]=0;
    }
    // Bear signal
    else {
      vdDn[i]=gadGap[iRow];
      vdUp[i]=0;
    }    
  }
  return(0);
}


//-----------------------------------------------------------------------------
// function: ProcessCCI()
// Description: Calc CCI data and update matrix
//-----------------------------------------------------------------------------
int ProcessCCI(int iNewBars, int iTF, int iPeriod, double& vdUp[], double& vdDn[], int iRow) {
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
    // No Data
    if (iClose(NULL,iTF,j)==0) {
      vdUp[i]=EMPTY_VALUE;
      vdDn[i]=EMPTY_VALUE;
    }
    // Bull signal
    else if (dSig>=0) {
      vdUp[i]=gadGap[iRow];
      vdDn[i] = 0;
    }
    // Bwar signal
    else {
      vdDn[i]=gadGap[iRow];
      vdUp[i] = 0;
    } 
  }
  return(0);
}


//-----------------------------------------------------------------------------
// function: ProcessGannHiLo()
// Description: Calc GannHiLo data and update matrix
//-----------------------------------------------------------------------------
int ProcessGannHiLo(int iNewBars, int iTF, int iPeriod, double& vdUp[], double& vdDn[], int iRow) {
  int i,j,iUp;
  int iHTFBar=-1;
    
  // Draw tape chart
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
      iUp = (int)iCustom(NULL,iTF,IND_GANNHILO,GannHiLo_Period,0,j);
    }
    // No Data
    if (iUp==EMPTY_VALUE) {
      vdUp[i]=0;
      vdDn[i]=0;
    }
    // Bull signal
    else if (iUp==1) {
      vdUp[i]=gadGap[iRow];
      vdDn[i]=0;
    }
    // Bear signal
    else {
      vdDn[i]=gadGap[iRow];
      vdUp[i]=0;
    }
  }
  return(0);
}  


//-----------------------------------------------------------------------------
// function: ProcessT3MA()
// Description: Calc T3MA data and update matrix
//-----------------------------------------------------------------------------
int ProcessT3MA(int iNewBars, int iTF, int iPeriod, double db, int iMaxBars, double& vdUp[], double& vdDn[], int iRow) {
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
    // Calc T3MA data
    if (iHTFBar!=j) {
      iHTFBar=j;
      dSig0 = iCustom(NULL,iTF,IND_T3MA,iPeriod,db,iMaxBars,0,j);
      dSig1 = iCustom(NULL,iTF,IND_T3MA,iPeriod,db,iMaxBars,0,j+1);
    }
    // No Data
    if (iClose(NULL,iTF,j)==0) {
      vdUp[i]=EMPTY_VALUE;
      vdDn[i]=EMPTY_VALUE;
    }
    // Bull signal
    else if (dSig0>=dSig1) {
      vdUp[i]=gadGap[iRow];
      vdDn[i]=0;
    }
    // Bear signal
    else {
      vdDn[i]=gadGap[iRow];
      vdUp[i]=0;
    }
  }
  return(0);
}  


//-----------------------------------------------------------------------------
// function: CheckAlert()
// Description: Check for new alerts
//-----------------------------------------------------------------------------
void CheckAlert(int iTF) {
  static datetime tAlertBar;
  static int iPrevAlert=0;
  
  if (Alert_Popup || Alert_Email || Alert_Sound!="") {
    
    // Alert on the close of the current bar
    if (Alert_OnBarClose && tAlertBar<Time[iBarShift(Symbol(), iTF, Time[0])] && !gbInit) {
      
      tAlertBar=Time[iBarShift(Symbol(), iTF, Time[0])];
      // Clear alert flag
      if (iPrevAlert==1 && !UpSignal(1))
         iPrevAlert=0;
      else if (iPrevAlert==-1 && !DnSignal(1))
         iPrevAlert=0;
      // Alert and set alert flag
      if (UpSignal(1) && iPrevAlert!=1) {
         AlertNow(Symbol()+", "+TF2Str(iTF)+": Genesis Matrix Buy Signal.");
         iPrevAlert=1;
      }  
      else if (DnSignal(1) && iPrevAlert!=-1) {
         AlertNow(Symbol()+", "+TF2Str(iTF)+": Genesis Matrix Sell Signal.");
         iPrevAlert=-1;
      }
    }
  
    // Alert while the current bar is open
    if (!Alert_OnBarClose && tAlertBar<Time[iBarShift(Symbol(), iTF, Time[0])] && !gbInit) {
      // Clear alert flag
      if (iPrevAlert==1 && !UpSignal(0))
         iPrevAlert=0;
      else if (iPrevAlert==-1 && !DnSignal(0))
         iPrevAlert=0;      
      // Alert and set alert flag
      if (UpSignal(0) && iPrevAlert!=1) {
         AlertNow(Symbol()+", "+TF2Str(iTF)+": Genesis Matrix Buy Signal.");
         iPrevAlert=1;
         tAlertBar=Time[iBarShift(Symbol(), iTF, Time[0])];
      }  
      else if (DnSignal(0) && iPrevAlert!=-1) {
         AlertNow(Symbol()+", "+TF2Str(iTF)+": Genesis Matrix Sell Signal.");
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
  //Popup Alert 
  if (Alert_Popup) 
    Alert(INDICATOR_NAME, ", ", sAlertMsg);
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
// Description: Return true if there is an up signal
//-----------------------------------------------------------------------------
bool UpSignal(int i) {
  if (gadR1Up[i]>0 && gadR2Up[i]>0 && gadR3Up[i]>0 && gadR4Up[i]>0)
    return(True);
  else
    return(False);
}


//-----------------------------------------------------------------------------
// function: DnSignal()
// Description: eturn true if there is a down signal
//-----------------------------------------------------------------------------
bool DnSignal(int i) {
  if (gadR1Dn[i]>0 && gadR2Dn[i]>0 && gadR3Dn[i]>0 && gadR4Dn[i]>0)
    return(True);
  else
    return(False);
}


//-----------------------------------------------------------------------------
// function: Writelabel()
// Description: Write a label for a bar
//-----------------------------------------------------------------------------
int Writelabel(string sLabel,double dPrice) {
  string sObjId;
  sObjId=gsIndicatorName+"_"+sLabel;
  if(ObjectFind(sObjId) < 0) 
    ObjectCreate(sObjId, OBJ_TEXT, WindowFind(gsIndicatorName), Time[0]+Period()*60*2, dPrice);
  ObjectSetText(sObjId, sLabel, 6, "Lucida Console", Label_Color);
  ObjectMove(sObjId,0,Time[0]+Period()*60*2, dPrice);
  return(0);
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




