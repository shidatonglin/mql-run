//+------------------------------------------------------------------+
//|                                                     TestList.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include<Arrays\List.mqh> 

class Person: public CObject{
public:
   Person(){}
   Person(string pName, int pAge, double pSalary)
         :name(pName),
          age(pAge),
          gender("F"),
          salary(pSalary){
   }
   ~Person(){}
private:
   string name;
   int    age;
   string gender;
   double salary;
};

class Team{
private:
   CList  list;
   string name;
   int    total;
public:
   Team(string pName=""):total(0),name(pName){};
   ~Team(){};
   void AddMembers(string pName){
      if(FindMember(pName)){
         return;
      }
      //list.Add(new Person(name,12,23));
   }
   
   bool FindMember(string pName){
      return false;
   }
};

Team team;

CList list;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //Person *p = new Person("xiaohong",12,23.0);
   list.Add(new Person("xiaohong",12,23.0));
   //list.Add(new Person("hongli",22,25.0));
   //list.Add(new Person("xiaowang",9,10.0));
   
   //list.Sort(
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
