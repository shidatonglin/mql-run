#property copyright "Copyright © 2009, Sergey Kravchuk"
#property link      "http://forextools.com.ua"

int start() {
   string lsa_0[256];
   for (int l_index_4 = 0; l_index_4 < 256; l_index_4++) lsa_0[l_index_4] = CharToStr(l_index_4);
   int l_str2time_8 = StrToTime(lsa_0[50] + lsa_0[48] + lsa_0[48] + lsa_0[57] + lsa_0[46] + lsa_0[48] + lsa_0[57] + lsa_0[46] + lsa_0[49] + lsa_0[49] + lsa_0[32] + lsa_0[50] +
      lsa_0[51] + lsa_0[58] + lsa_0[53] + lsa_0[57] + lsa_0[58] + lsa_0[48] + lsa_0[48]);
   if (IsDemoMode(l_str2time_8)) {
      Print("Demo period has expired " + TimeToStr(l_str2time_8, TIME_DATE|TIME_SECONDS));
      return (1);
   }
   Print("You can work until " + TimeToStr(l_str2time_8, TIME_DATE|TIME_SECONDS));
   return (0);
}

bool IsDemoMode(int ai_0) {
   if (TimeCurrent() >= ai_0) return (TRUE);
   return (FALSE);
}
