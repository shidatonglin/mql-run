//+------------------------------------------------------------------+
//|                                                     LSMA nrp.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property  copyright "copyleft mladen"
#property  link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 LightGray
#property indicator_color2 DodgerBlue
#property indicator_color3 DodgerBlue
#property indicator_color4 DeepPink
#property indicator_color5 DeepPink
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

//
//
//
//
//

extern int    LSMAPeriod   = 23;
extern int    LSMAPrice    =  0;
//
//
//
//
//

double lsma[];
double lsmaua[];
double lsmaub[];
double lsmada[];
double lsmadb[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,lsma);
   SetIndexBuffer(1,lsmaua);
   SetIndexBuffer(2,lsmaub);
   SetIndexBuffer(3,lsmada);
   SetIndexBuffer(4,lsmadb);
   return(0);
}

//
//
//
//
//

int start()
{ 
   int      counted_bars=IndicatorCounted();
   int      limit,i;

   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   if (lsma[limit] > lsma[limit+1]) CleanPoint(limit,lsmaua,lsmaub);
   if (lsma[limit] < lsma[limit+1]) CleanPoint(limit,lsmada,lsmadb);
   for(i = limit; i >= 0; i--)
   {
      lsma[i]   = 3.0*iMA(NULL,0,LSMAPeriod,0,MODE_LWMA,LSMAPrice,i)-2.0*iMA(NULL,0,LSMAPeriod,0,MODE_SMA,LSMAPrice,i);
      lsmaua[i] = EMPTY_VALUE;
      lsmaub[i] = EMPTY_VALUE;
      lsmada[i] = EMPTY_VALUE;
      lsmadb[i] = EMPTY_VALUE;
         if (lsma[i] > lsma[i+1]) PlotPoint(i,lsmaua,lsmaub,lsma);
         if (lsma[i] < lsma[i+1]) PlotPoint(i,lsmada,lsmadb,lsma);
   }   
   return(0);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}