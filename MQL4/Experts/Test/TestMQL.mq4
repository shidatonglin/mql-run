//+------------------------------------------------------------------+
//|                                                      TestMQL.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class Person{
private:
   int m_age;
   string m_name;
public:
   Person();
   ~Person();
   void PrintInfo();
};

Person::Person(void):m_age(-1){}

Person::~Person(void){}

void Person::PrintInfo(void){
   Print("name : " , m_name, " \n age: ", m_age);
}

Person p;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   p.PrintInfo();
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
