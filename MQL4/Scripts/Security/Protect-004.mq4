//+------------------------------------------------------------------+
//|                                                  Protect-004.mq4 |
//|                                Copyright © 2009, Sergey Kravchuk |
//|                                         http://forextools.com.ua |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Sergey Kravchuk"
#property link      "http://forextools.com.ua"

int start()
{  
  string char[256]; int i;

  for (i = 0; i < 256; i++) char[i] = CharToStr(i);
  // Account number, on which expert is allowed to work
  int    AllowedAccountNo = StrToInteger(/* 49153 */ char[52]+char[57]+char[49]+char[53]+char[51]); 
  string AllowedServer    = /* UWC-Demo.com */       char[85]+char[87]+char[67]+char[45]+char[68]+
                               char[101]+char[109]+char[111]+char[46]+char[99]+char[111]+char[109];

  if (AccountNumber() != AllowedAccountNo || AccountServer() != AllowedServer) 
  {
    Print("You don't have permission to use this script!");
    return(1);
  }
  
  Print("You can use this script!");
}

