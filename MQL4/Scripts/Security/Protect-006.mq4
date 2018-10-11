//+------------------------------------------------------------------+
//|                                                  Protect-006.mq4 |
//|                                Copyright © 2009, Sergey Kravchuk |
//|                                         http://forextools.com.ua |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Sergey Kravchuk"
#property link      "http://forextools.com.ua"

int start()
{  
  string char[256]; int i;

  for (i = 0; i < 256; i++) char[i] = CharToStr(i);

  // Date, until which the expert is allowed to work
  int LastAllowedDate = StrToTime(
  /* 2009.09.11 23:59:00 */ 
  char[50]+char[48]+char[48]+char[57]+char[46]+char[48]+char[57]+char[46]+char[49]+
  char[49]+char[32]+char[50]+char[51]+char[58]+char[53]+char[57]+char[58]+char[48]+char[48]

  ); 

  if (IsDemoMode(LastAllowedDate)) 
  {
    Print("Demo period has expired " + TimeToStr(LastAllowedDate,TIME_DATE|TIME_SECONDS));
    return(1);
  }
  
  Print("You can work until "+ TimeToStr(LastAllowedDate,TIME_DATE|TIME_SECONDS));
}

bool IsDemoMode(int LastAllowedDate)
{
  if (TimeCurrent() >= LastAllowedDate) return(true); else return(false); 
}

