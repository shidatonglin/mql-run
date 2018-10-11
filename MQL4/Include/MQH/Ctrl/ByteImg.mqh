//+------------------------------------------------------------------+
//|                                                           Buffer |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2014"
#property version		"1.00"
#property library

#include "FastFile.mqh"
//+------------------------------------------------------------------+
//| CBuffer class                                                    |
//+------------------------------------------------------------------+
class CByteImg
  {
public:
   void Clear() { ArrayResize(m_data,0); };
   bool Copy(const CByteImg &a) { ArrayCopy(m_data,a.m_data); return(true); };

public:
   //--- byte array
   uchar             m_data[];
   //--- specific data
   uchar             __b[];

public:
                     CByteImg() { Clear(); };
                     CByteImg(uchar &data[]) { Clear(); AssignArray(data); };
                    ~CByteImg() { Clear(); };

public:
   int Len() { return(ArraySize(m_data)); }
   int Size() { return(Len()); }

public:
   void Append(uchar byte) { int sz=ArraySize(m_data); ArrayResize(m_data,sz+1); m_data[sz]=byte; }
   //--- File write functions
   uint AssignArray(uchar &src[],uint src_start=0,int src_cnt=WHOLE_ARRAY) { int r=ArrayCopy(m_data,src,0,src_start,src_cnt); return(r); }
   uint AssignDouble(double v) { __dbl d; d.v=v; return(AssignArray(d.b)); }
   uint AssignFloat(float v){ __float d; d.v=v; return(AssignArray(d.b)); }
   uint AssignInt64(long v){ __long d; d.v=v; return(AssignArray(d.b)); }
   uint AssignInt(int v){ __int d; d.v=v; return(AssignArray(d.b)); }
   uint AssignShort(short v){ __short d; d.v=v; return(AssignArray(d.b)); }
   uint AssignChar(char v){ __char d; d.v=v; return(AssignArray(d.b)); }
   uint AssignString(string v) { StringToCharArray(v,__b,0,StringLen(v)); return(AssignArray(__b)); }

public:
   //--- File read functions
   uint ViewArray(uchar &dst[],uint dst_start,int cnt) { int r=ArrayCopy(dst,m_data,dst_start,0,cnt); return(r); }
   double ViewDouble() { __dbl d={0}; ViewArray(d.b,0,8); return(d.v); }
   float ViewFloat() { __float d={0}; ViewArray(d.b,0,4); return(d.v); }
   long ViewInt64() { __long d={0}; ViewArray(d.b,0,8); return(d.v); }
   int ViewInt() { __int d={0}; ViewArray(d.b,0,4); return(d.v); }
   short ViewShort() { __short d={0}; ViewArray(d.b,0,2); return(d.v); }
   char ViewChar() { __char d={0}; ViewArray(d.b,0,1); return(d.v); }
   string ViewString() { ViewArray(__b,0,WHOLE_ARRAY); return(CharArrayToString(__b)); }
  };
//+------------------------------------------------------------------+
