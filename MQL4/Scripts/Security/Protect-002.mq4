//+------------------------------------------------------------------+
//|                                                  Protect-002.mq4 |
//|                                Copyright © 2009, Sergey Kravchuk |
//|                                         http://forextools.com.ua |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Sergey Kravchuk"
#property link      "http://forextools.com.ua"

#property show_inputs

extern string prefix = "char";
extern string text = "input your text for encoding";
string rez = ""; // here we will assemble the result

int start()
{
  // enter the original text to see what this string is
  rez = "/* " + text + " */ "; 
  
  for (int i = 0; i < StringLen(text); i++) 
  rez = rez + prefix + "[" + StringGetChar(text, i) + "]+";
  
  // cut the last '+' character and print string to the log
  Print(StringSubstr(rez, 0, StringLen(rez)-1)); 
}

