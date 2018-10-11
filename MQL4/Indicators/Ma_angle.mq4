//+------------------------------------------------------------------+
//|                                                     MA_Angle.mq4 |
//| Modified from code for EMA_Angle by jpkfox                       |
//|                                                                  |
//| You can use this indicator to measure when the MA angle is       |
//| "near zero". AngleTreshold determines when the angle for the     |
//| MA is "about zero": This is when the value is between            |
//| [-AngleTreshold, AngleTreshold] (or when the histogram is red).  |
//|   MAPeriod: MA period                                            |
//|   AngleTreshold: The angle value is "about zero" when it is      |
//|     between the values [-AngleTreshold, AngleTreshold].          |      
//|   StartMAShift: The starting point to calculate the              |   
//|     angle. This is a shift value to the left from the            |
//|     observation point. Should be StartMAShift > EndMAShift.      | 
//|   EndMAShift: The ending point to calculate the                  |
//|     angle. This is a shift value to the left from the            | 
//|     observation point. Should be StartMAShift > EndMAShift.      |
//|                                                                  |
//|   Modified by MrPip                                              |
//|       Red for down                                               |
//|       Yellow for near zero                                       |
//|       Green for up                                               |
//|  10/15/05  MrPip                                                 |
//|            Corrected problem with USDJPY and optimized code      |
//|  10/23/05  Added other JPY crosses                               |   
//|                                                                  |
//|   8/1/2006 Modified to use any MA including LSMA                 |                                                                  |
//|                                                                  |
//|  05/05/08 Added SMAPeriod2 for use with iMAOnArray for           |
//|           moving average of histogram                            |
//+------------------------------------------------------------------+

#property  copyright "MrPip and jpkfox"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  LimeGreen
#property  indicator_color2  Yellow
#property  indicator_color3 FireBrick
//---- indicator parameters
extern int MAPeriod=50;
extern string  m = "--Moving Average Types--";
extern string  m0 = " 0 = SMA";
extern string  m1 = " 1 = EMA";
extern string  m2 = " 2 = SMMA";
extern string  m3 = " 3 = LWMA";
extern string  m4 = " 4 = LSMA";
extern int MA_Type = 0;
extern string  p = "--Applied Price Types--";
extern string  p0 = " 0 = close";
extern string  p1 = " 1 = open";
extern string  p2 = " 2 = high";
extern string  p3 = " 3 = low";
extern string  p4 = " 4 = median(high+low)/2";
extern string  p5 = " 5 = typical(high+low+close)/3";
extern string  p6 = " 6 = weighted(high+low+close+close)/4";
extern int MA_AppliedPrice = 0;
extern double AngleTreshold=0.25;
extern int PrevMAShift=2;
extern int CurMAShift=0;

int MA_Mode;
string strMAType;

//---- indicator buffers
double UpBuffer[];
double DownBuffer[];
double ZeroBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- 1 additional buffers are used for counting.
//   IndicatorBuffers(5);
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);

   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,UpBuffer) &&
      !SetIndexBuffer(1,DownBuffer) &&
      !SetIndexBuffer(2,ZeroBuffer))
      Print("cannot set indicator buffers!");
switch (MA_Type)
   {
      case 1: strMAType="EMA"; MA_Mode=MODE_EMA; break;
      case 2: strMAType="SMMA"; MA_Mode=MODE_SMMA; break;
      case 3: strMAType="LWMA"; MA_Mode=MODE_LWMA; break;
      case 4: strMAType="LSMA"; break;
      default: strMAType="SMA"; MA_Mode=MODE_SMA; break;
   }
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName(strMAType+"_Angle("+MAPeriod+","+AngleTreshold+","+PrevMAShift+","+CurMAShift+")");
//---- initialization done
   return(0);
}

//+------------------------------------------------------------------+
//| LSMA with PriceMode                                              |
//| PrMode  0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2,    |
//| 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4  |
//+------------------------------------------------------------------+

double LSMA(int LSMAPeriod, int LSMAPrice,int shift)
{
   double wt;
   
   double ma1=iMA(NULL,0,LSMAPeriod,0,MODE_SMA ,LSMAPrice,shift);
   double ma2=iMA(NULL,0,LSMAPeriod,0,MODE_LWMA,LSMAPrice,shift);
   wt = MathFloor((3.0*ma2-2.0*ma1)/Point)*Point;
   return(wt);
}  

//+------------------------------------------------------------------+
//| The angle for MA                                                |
//+------------------------------------------------------------------+
int start()
{
   double fCurMA, fPrevMA;
   double fAngle, mFactor, dFactor;
   int nLimit, i;
   int nCountedBars;
   double angle;
   int ShiftDif;
   string Sym;
 
   if (MA_Type > 4) MA_Mode = 0;
   if(CurMAShift >= PrevMAShift)
   {
      Print("Error: CurMAShift >= PrevMAShift");
      PrevMAShift = 6;
      CurMAShift = 0;      
   }  
         
   nCountedBars = IndicatorCounted();
//---- check for possible errors
   if(nCountedBars<0) 
      return(-1);
//---- last counted bar will be recounted
   if(nCountedBars>0) 
      nCountedBars--;
   nLimit = Bars-nCountedBars;
   dFactor = 2*3.14159/180.0;
   mFactor = 10000.0;
   Sym = StringSubstr(Symbol(),3,3);
   if (Sym == "JPY") mFactor = 100.0;
   ShiftDif = PrevMAShift-CurMAShift;
   mFactor /= ShiftDif; 
//---- main loop
   for(i=0; i<nLimit; i++)
   {
      if (MA_Type == 4)
      {
        fCurMA=LSMA(MAPeriod,MA_AppliedPrice, i+CurMAShift);
        fPrevMA=LSMA(MAPeriod,MA_AppliedPrice, i+PrevMAShift);
      }
      else
      {
        fCurMA=iMA(NULL,0,MAPeriod,0,MA_Mode,MA_AppliedPrice,i+CurMAShift);
        fPrevMA=iMA(NULL,0,MAPeriod,0,MA_Mode,MA_AppliedPrice,i+PrevMAShift);
      }
      // 10000.0 : Multiply by 10000 so that the fAngle is not too small
      // for the indicator Window.
      fAngle = mFactor * (fCurMA - fPrevMA)/2.0;
//      fAngle = (fCurMA - fPrevMA)/ShiftDif;
//      fAngle = mFactor * MathArctan(fAngle)/dFactor;

      DownBuffer[i] = 0.0;
      UpBuffer[i] = 0.0;
      ZeroBuffer[i] = 0.0;
      
      if(fAngle > AngleTreshold)
      {
         UpBuffer[i] = fAngle;
      }
      else if (fAngle < -AngleTreshold)
      {
         DownBuffer[i] = fAngle;
      }
      else ZeroBuffer[i] = fAngle;
   }

   return(0);
  }
//+------------------------------------------------------------------+

