//+------------------------------------------------------------------+
//|                                           2 MA Difference v1.mq4 |
//|                                        Copyright © 2011, tigpips |
//|                                                tigpips@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, tigpips"
#property link      "tigpips@gmail.com"

#property indicator_buffers 3
#property indicator_chart_window
#property indicator_color1 Magenta   
#property indicator_color2 Yellow

extern bool UseBarCount = true;
extern int BarCount = 10000;
extern color MA1TextColor = Orange;
extern color MA2TextColor = DeepSkyBlue;
extern color MADiffPositiveColor = Lime;
extern color MADiffNegativeColor = Red;
extern color MADiff0Color = White;
extern int font_size = 12;
extern int MA1_Period = 8;
extern int MA1_ma_shift = 0;
extern int MA1_ma_method = 0;
extern int MA1_ma_Applied_Price = 0;
extern int MA1_shift = 0;

extern int MA2_Period = 50;
extern int MA2_ma_shift = 0;
extern int MA2_ma_method = 0;
extern int MA2_ma_Applied_Price = 0;
extern int MA2_shift = 0;

extern int myXoffset = 0;
extern int myYoffset = 0;

double MA1[];
double MA2[];
double MADiff[];

string shortname = "2MADiff";
int init()
{
   IndicatorBuffers(3);
   IndicatorShortName(shortname);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0, MA1);
   SetIndexDrawBegin(0, MA1_Period);
   SetIndexLabel(0, "MA1");

   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(1, MA2);
   SetIndexDrawBegin(1, MA2_Period);
   SetIndexLabel(1, "MA2");
   
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,MADiff);    

   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll();
   return(0);
}

int start()
{
   int limit;
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   if(UseBarCount == true)
   {
      limit = MathMin(BarCount, Bars - 1 - counted_bars);
   }
   else
   {
      limit=MathMin(Bars-counted_bars,Bars-1);
   }
   for(int i = limit; i >= 0; i--)
   {
      MA1[i]=iMA(NULL,0,MA1_Period,MA1_ma_shift,MA1_ma_method,MA1_ma_Applied_Price,i+MA1_shift);
      MA2[i]=iMA(NULL,0,MA2_Period,MA2_ma_shift,MA2_ma_method,MA2_ma_Applied_Price,i+MA2_shift);
      MADiff[i] = MA1[i] - MA2[i];  
      DrawObjects(i); 
   }   
       
      
   return(0);
}
//+------------------------------------------------------------------+

void DrawObjects(int j)
{

   ObjectCreate(shortname + "MA1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText(shortname + "MA1","Moving Average 1 : "+DoubleToStr(MA1[j],Digits),font_size,"Arial Bold", MA1TextColor);
   ObjectSet(shortname + "MA1", OBJPROP_CORNER, 1);
   ObjectSet(shortname + "MA1", OBJPROP_XDISTANCE, 10+myXoffset);
   ObjectSet(shortname + "MA1", OBJPROP_YDISTANCE, 10+myYoffset);
   
   ObjectCreate(shortname + "MA2", OBJ_LABEL, 0, 0, 0);
   ObjectSetText(shortname + "MA2","Moving Average 2 : "+DoubleToStr(MA2[j],Digits),font_size,"Arial Bold", MA2TextColor);
   ObjectSet(shortname + "MA2", OBJPROP_CORNER, 1);
   ObjectSet(shortname + "MA2", OBJPROP_XDISTANCE, 10+myXoffset);
   ObjectSet(shortname + "MA2", OBJPROP_YDISTANCE, 30+myYoffset);
   
   ObjectCreate(shortname + "MADiff", OBJ_LABEL, 0, 0, 0);
   ObjectSetText(shortname + "MADiff","Difference : "+CheckIfPositive(MADiff[j]),font_size,"Arial Bold", CheckColor(MADiff[j]));
   ObjectSet(shortname + "MADiff", OBJPROP_CORNER, 1);
   ObjectSet(shortname + "MADiff", OBJPROP_XDISTANCE, 10+myXoffset);
   ObjectSet(shortname + "MADiff", OBJPROP_YDISTANCE, 50+myYoffset);   
}

string CheckIfPositive(double num)
{
   string result;
   if(num >0.0)
   {
      result = "+"+DoubleToStr(num,Digits);  
   }
   else if(num <0.0)
   {
      result = DoubleToStr(num,Digits);
   }
   return(result);
}

color CheckColor(double value1)
{
   color result;
   if(value1 >0.0)
   {
      result = MADiffPositiveColor;
   }
   else if(value1 <0.0)
   {
      result = MADiffNegativeColor;
   }
   else if(value1==0.0)
   {
      result = MADiff0Color;
   }
   return(result);
}