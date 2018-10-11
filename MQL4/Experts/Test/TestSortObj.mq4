//+------------------------------------------------------------------+
//|                                                  TestSortObj.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define EQUAL 0
#define LESS -1
#define MORE 1
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>

enum ENUM_SORT_TYPE
{
   SORT_BY_TEXT,
   SORT_BY_NUMBER
};

class CLineTable: public CObject
{
private:
   string m_text;
   int m_number;
public:
   CLineTable();
   CLineTable(string text, int number)
   {
      m_text = text;
      m_number = number;
   }
   string Text()const{return m_text;}
   int Number()const{return m_number;}
   virtual int Compare(const CObject *node,const int mode=0) const
   { 
      const CLineTable* line = node;
      switch (mode)
      {
         case SORT_BY_TEXT:
            if(line.Text() == this.Text())
               return EQUAL;
            else if(line.Text() < this.Text())
               return MORE;
            else
               return LESS;
         case SORT_BY_NUMBER:
            if(line.Number() == this.Number())
               return EQUAL;
            else if(line.Number() < this.Number())
               return MORE;
            else
               return LESS;
      }
      return EQUAL;
   }
};
CArrayObj Table;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void test()
  {
    //Добавляем в таблицу 13 строк CLineTable
    int limit = 13;
    Table.Sort(SORT_BY_TEXT);
    for(int i = 0; i < limit; i++)
    {
      string n = (string)(i+1);
      if(StringLen(n) < 2)n = "0"+n;
      string text = "Ticket" + n;
      Table.InsertSort(new CLineTable(text, limit-i));
    }
    //Смотрим что получилось:
    for(int i = 0; i < Table.Total(); i++)
    {
      CLineTable* line = Table.At(i);
      printf(line.Text() + " ->\t" + (string)line.Number());
    }
    //Сортируем по второму фактору: номера
    Table.Sort(SORT_BY_NUMBER);
    //Смотрим что получилось:
    printf("");
    for(int i = 0; i < Table.Total(); i++)
    {
      CLineTable* line = Table.At(i);
      printf(line.Text() + " ->\t" + (string)line.Number());
    }
    Table.Clear();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   test();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
