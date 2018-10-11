//+------------------------------------------------------------------+
//|                                          4h_MACD_FX_Strategy.mq4 |
//|                                     Giorgio "Obi Wan" Scarabello |
//|                            http://www.fxtradeblog.com/index.html |
//+------------------------------------------------------------------+
#property copyright "Giorgio Obi Wan Scarabello"
#property link      "http://www.fxtradeblog.com/index.html"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 SkyBlue
#property indicator_color2 MediumSeaGreen
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Green

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 2
#property indicator_width4 3
#property indicator_width5 1

#property indicator_style1 2
#property indicator_style2 2
#property indicator_style3 0
#property indicator_style4 0
#property indicator_style5 2
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];

//---- Variables
double EMA8=0.0;
double EMA21=0.0;
double SMA89=0.0;
double SMA200=0.0;
double EMA365=0.0;

int rhythm=0;
string rh="";
int x=0;
int limit;
int col=0xFFFFFF;

extern int fontsize = 10;
extern int corner = 3;
//extern bool orientation = 0;
extern int xdispl = 1;
extern int ydispl = 1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"EMA 8");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"EMA 21");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexLabel(2,"SMA 89");
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexLabel(3,"SMA 200");
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexLabel(4,"EMA 365");
//----

//---- Text Object
   ObjectCreate("Rhythm", OBJ_LABEL, 0, 0, 0);
   //ObjectSetText("Range", gs_rRange,fontsize,"Arial",Yellow);
   ObjectSet("Rhythm", OBJPROP_CORNER, corner);
   ObjectSet("Rhythm", OBJPROP_XDISTANCE, xdispl);
   ObjectSet("Rhythm", OBJPROP_YDISTANCE, ydispl);
   
//---- Line Objects
   ObjectCreate("Roundover", OBJ_HLINE, 0, 0, 0);
   ObjectSet("Roundover", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("Roundover", OBJPROP_COLOR, Lime);
   
   ObjectCreate("Roundunder", OBJ_HLINE, 0, 0, 0);
   ObjectSet("Roundunder", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("Roundunder", OBJPROP_COLOR, Red);
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("Rhythm");
   ObjectDelete("Roundover");
   ObjectDelete("Roundunder");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
if(counted_bars>0) counted_bars--;
limit=Bars-counted_bars;

//Moving averages stuff
for (x=limit; x>=0; x--)
   {
      //calculation
      EMA8=iMA(NULL,0,8,0,MODE_EMA,PRICE_CLOSE,x);
      EMA21=iMA(NULL,0,21,0,MODE_EMA,PRICE_CLOSE,x);
      SMA89=iMA(NULL,0,89,0,MODE_SMA,PRICE_CLOSE,x);
      SMA200=iMA(NULL,0,200,0,MODE_SMA,PRICE_CLOSE,x);
      EMA365=iMA(NULL,0,365,0,MODE_EMA,PRICE_CLOSE,x);
      
      //drawing
      ExtMapBuffer1[x]=EMA8;
      ExtMapBuffer2[x]=EMA21;
      ExtMapBuffer3[x]=SMA89;
      ExtMapBuffer4[x]=SMA200;
      ExtMapBuffer5[x]=EMA365;        
   }
   
//Rhythm stuff
rhythm=0;
if (Close[0]>SMA89)
   {
      rhythm=1;
      rh="Weak Bull Rhythm Strength";
      col=0xAAFFAA;
      
      if (Close[0]>EMA8)
      {
         rhythm++;
         rh="Strong Bull Rhythm Strength";
         col=0x00FF00;
         
      }
    }
 else if (Close[0]<SMA89)
   {
      rhythm=-1;
      rh="Weak Bear Rhythm Strength";
      col=0xAAAAFF;
      
      if (Close[0]<EMA8)
         {
            rhythm--;
            rh="Strong Bear Rhythm Strength";
            col=0x0000FF;
            
         }
   }
 else
   {
      rhythm=0;
      rh="No Rhythm Strength";
      col=0xFFFFFF;
   }
   
 ObjectSetText("Rhythm", "Rhythm="+rhythm+" "+rh,fontsize,"Tahoma",col);
 
 
//---- Lines stuff

//---- Price calculation
string hs1, hs2;
double hv1, hv2;

hs1=DoubleToStr( Close[0], Digits);
hs1=StringSubstr( hs1, 0, 4);
hs1=hs1+"00";
hv1= StrToDouble(hs1);
if (Digits==4)
   {
      hv1=hv1+0.01;
   }
else
   {
      hv1++;
   }


hs2=DoubleToStr( Close[0], Digits);
hs2=StringSubstr( hs2, 0, 4);
hs2=hs2+"00";
hv2= StrToDouble(hs2);

//---- Drawing
ObjectSet("Roundover", OBJPROP_PRICE1, hv1);
ObjectSet("Roundunder", OBJPROP_PRICE1, hv2);

//----
   return(0);
  }
//+------------------------------------------------------------------+