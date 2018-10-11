//+------------------------------------------------------------------+
//|                                                  Protect-003.mq4 |
//|                                Copyright © 2009, Sergey Kravchuk |
//|                                         http://forextools.com.ua |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Sergey Kravchuk"
#property link      "http://forextools.com.ua"

int start()
{  
  string char[256]; int i;

  for (i = 0; i < 256; i++) char[i] = CharToStr(i);

  Comment
  (
    /* Copyright © 2009, Sergey Kravchuk*/ 
    char[67]+char[111]+char[112]+char[121]+char[114]+char[105]+char[103]+
    char[104]+char[116]+char[32]+char[169]+char[32]+char[50]+char[48]+
    char[48]+char[57]+char[44]+char[32]+char[83]+char[101]+char[114]+
    char[103]+char[101]+char[121]+char[32]+char[75]+char[114]+char[97]+
    char[118]+char[99]+char[104]+char[117]+char[107]
  );
  return(0);
}

