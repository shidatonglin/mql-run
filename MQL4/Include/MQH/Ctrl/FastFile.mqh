//+------------------------------------------------------------------+
//|                                                         FastFile |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2012"
#property version		"1.00"
#property library
//+------------------------------------------------------------------+
//| CFastFile class                                                  |
//+------------------------------------------------------------------+
class CFastFile
{
	//--- структуры перевода величин в байтовые массивы	
	union __dbl { double v; uchar b[8]; };
	union __float { float v; uchar b[4]; };
	union __long { long v; uchar b[8]; };
	union __int { int v;  uchar b[4]; };
	union __short { short v; uchar b[2]; };
	union __char { char v; uchar b[1]; };
	
public:
	virtual void Clear() { m_pos=0; m_size=0; ArrayResize(m_data,0); };
	virtual bool Copy(const CFastFile& a) { ArrayCopy(m_data, a.m_data); m_size=a.m_size; m_pos=a.m_pos; m_delim=a.m_delim; return true; };

public:
	uchar             m_data[];   // байтовый массив
	int               m_size;     // размер
	int               m_pos;      // текущее положение
	uchar             m_delim;    // символ разделения данных в CSV режиме

public:
	CFastFile() { Clear(); m_delim=';'; };
	CFastFile(const CFastFile& a) { Copy(a); };
	CFastFile(uchar &data[]) { Clear(); WriteArray(data); m_pos=0; m_delim=';'; };
	void operator=(const CFastFile& a) { Copy(a); };
	~CFastFile() { Clear(); };
	
public:
   // функции работы со свойствами файла
   void Delim(uchar delim=';') { m_delim=delim; } // задание разделителя данных при CSV режиме
   int Size() { m_size=ArraySize(m_data); return(m_size); } // получение размера файла
   int Tell() { return(m_pos); } // получение текущей позиции указателя
   
   void Seek(int offset,int origin) // перемещение позиции указателя
     {
      if(origin==SEEK_SET) m_pos=offset;
      if(origin==SEEK_CUR) m_pos+=offset;
      if(origin==SEEK_END) m_pos=m_size-offset;
      m_pos=(m_pos<0)?0:m_pos;
      m_pos=(m_pos>m_size)?m_size:m_pos; // выровнили
     }
	bool IsEnding() { return(m_pos>=m_size); } // проверка достигнут ли конец файла
	bool IsLineEnding() { return(m_data[m_pos]=='\r' || m_data[m_pos]=='\n'); } // проверка достигнут ли конец строки
	
public:
	// функции записи в файл
	uint WriteArray(uchar &src[],uint src_start=0,int src_cnt=WHOLE_ARRAY) // запись байтового массива
	{ int r=ArrayCopy(m_data,src,m_pos,src_start,src_cnt); if(r>0) { m_pos+=r; m_size=ArraySize(m_data); } return(r); }
	//--- запись числа
	uint WriteDouble(double v) { __dbl d; d.v=v; return(WriteArray(d.b)); }
	uint WriteFloat(float v){ __float d; d.v=v; return(WriteArray(d.b)); }
	uint WriteLong(long v){ __long d; d.v=v; return(WriteArray(d.b)); }
	uint WriteInt(int v){ __int d; d.v=v; return(WriteArray(d.b)); }
	uint WriteShort(short v){ __short d; d.v=v; return(WriteArray(d.b)); }
	uint WriteChar(char v){ __char d; d.v=v; return(WriteArray(d.b)); }
	//--- запись числа - для совместимости перехода с FileWriteInteger
	uint WriteInteger(int v,int sz=INT_VALUE)
     {
      if(sz==CHAR_VALUE) return(WriteChar((char)v));
      if(sz==SHORT_VALUE) return(WriteShort((short)v));
      return(WriteInt(v));
     }
   //--- запись строки
   uint WriteString(string v)
     {
      uchar b[];
      StringToCharArray(v,b,0,StringLen(v));
      return(WriteArray(b));
     }
   //--- запись строки. cnt=-1 обозначает CSV режим записи с добавлением \r\n
   uint WriteString(string v,int cnt)
     {
      uchar b[];
      StringToCharArray(v,b,0,cnt);
      uint w=WriteArray(b);
      if(cnt<0) { WriteChar('\r'); WriteChar('\n'); }
      return(w+2*(cnt<0));
     }

public:
   //--- функции чтения из файла
   //--- чтение массива
   uint ReadArray(uchar &dst[],uint dst_start=0,int cnt=WHOLE_ARRAY)
     {
      int r=ArrayCopy(dst,m_data,dst_start,m_pos,cnt);
      if(r>0) m_pos+=r;
      return(r);
     }
   double ReadDouble() { __dbl d; ReadArray(d.b,0,8); return(d.v); }
   float ReadFloat()   { __float d; ReadArray(d.b,0,4); return(d.v); }
   long ReadLong()     { __long d; ReadArray(d.b,0,8); return(d.v); }
   int ReadInt()       { __int d; ReadArray(d.b,0,4); return(d.v); }
   short ReadShort()   { __short d; ReadArray(d.b,0,2); return(d.v); }
   char ReadChar()     { __char d; ReadArray(d.b,0,1); return(d.v); }
   //--- чтение числа - для совместимости перехода с FileReadInteger
   int ReadInteger(int sz=INT_VALUE)
     {
      if(sz==CHAR_VALUE) return(ReadChar());
      if(sz==SHORT_VALUE) return(ReadShort());
      return(ReadInt());
     }
   double ReadNumber() { return(StringToDouble(ReadString(-1))); } // читаем число до разделителя и преобразовываем в double
   //--- чтение строки. cnt=-1 обозначает CSV режим чтения до разделителя
   string ReadString(int cnt)
     {
      int i; bool b=false; uchar c=0;
      if(cnt<0)
        {
         for(i=m_pos; i<m_size; i++)
           {
            c=m_data[i];
            if(c==m_delim || c=='\r' || c=='\n') break;
           }
         cnt=i-m_pos; b=true;
        } // находим разделитель
      uchar dst[];
      ReadArray(dst,0,cnt);
      if(b) m_pos+=1+(c=='\r');
      m_pos=(m_pos>m_size)?m_size:m_pos;
      return(CharArrayToString(dst));
     }

public:
   //--- функции сохранения файла в другой исторчник
   //--- сохранение файла в байтовый массив
   uint Save(uchar &v[]) { return((uint)ArrayCopy(v,m_data,0,0)); };
   //--- сохранение файла в реальный файл на диске. h - заранее открытый дескриптор
   uint Save(int h) { return(FileWriteArray(h,m_data)); };
   //--- сохранение файла в реальный файл на диске. file - имя файла на диске
   uint Save(string file)
     {
      int h=FileOpen(file,FILE_BIN|FILE_ANSI|FILE_WRITE|FILE_SHARE_WRITE);
      if(h<=0) return(0);
      FileSeek(h,0,SEEK_SET);
      uint s=FileWriteArray(h,m_data);
      FileClose(h);
      return(s);
     }

public:
   //--- функции загрузки файла из другого источника
   //--- чтение файла из байтового массива
   uint Load(uchar &v[])
     {
      m_pos=0;
      ArrayResize(m_data,0);
      uint r=ArrayCopy(m_data,v);
      m_size=ArraySize(m_data);
      return(r);
     };
   //--- чтение файла из реального файла на диске. h - заранее открытый дескриптор  
   uint Load(int h)
     {
      m_pos=0;
      ArrayResize(m_data,0);
      uint r=FileReadArray(h,m_data,0,int(FileSize(h)-FileTell(h)));
      m_size=ArraySize(m_data);
      return(r);
     };
   //--- чтение файла из реального файла на диске. file - имя файла на диске
   uint Load(string file)
     {
      int h=FileOpen(file,FILE_BIN|FILE_ANSI|FILE_READ|FILE_SHARE_READ);
      if(h<=0) return(0);
      m_pos=0;
      ArrayResize(m_data,0);
      uint r=FileReadArray(h,m_data,0,int(FileSize(h)));
      m_size=ArraySize(m_data);
      FileClose(h);
      return(r);
     }
  };
//+------------------------------------------------------------------+
