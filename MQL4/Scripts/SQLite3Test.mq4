//+------------------------------------------------------------------+
//|                                                  SQLite3Test.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MQH\Lib\SQLite3\SQLite3Base.mqh>

CSQLite3Base sql3;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
//--- open database connection
   string dbfile = "C:\Users\ttong017\AppData\Roaming\MetaQuotes\Terminal\EDE118D48AFC8F98360529E5B06F4885\MQL4\Files\SQLite"
   if(sql3.Connect("SQLite3Test2.db3")!=SQLITE_OK)
      return;
   CSQLite3Table tbl;
/*
//--- 1. How to create a table
   if(sql3.Query("CREATE TABLE IF NOT EXISTS `TestQuery` (`ticket` INTEGER, `open_price` DOUBLE, `comment` TEXT)")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return;
     }

//--- 2. How to rename a table
   CSQLite3Table tbl;
   if(sql3.Query(tbl,"SELECT `name` FROM `sqlite_master` WHERE `type`='table' AND `name`='Trades'")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return;
     }
   if(ArraySize(tbl.m_data)<=0)// no data
      //if(sql3.Query("ALTER TABLE `TestQuery` RENAME TO `Trades`")!=SQLITE_DONE)
        {
         Print(sql3.ErrorMsg());
         return;
        }
 
//--- 3. How to add a column
   //if(sql3.Query("ALTER TABLE `Trades` ADD COLUMN `profit`")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      //return;
     }

//--- 4. How to add data
   if(sql3.Query("INSERT INTO `Trades` VALUES(3, 5.212, 'info', 1)")!=SQLITE_DONE)
     {
      Print("+++++++",sql3.ErrorMsg());
      return;
     }

//--- 5. How to update data by condition + binding
   CSQLite3Row row;
   row.Add(5.555);
   row.Add("New price");
   //if(sql3.QueryBind(row,"UPDATE `Trades` SET `open_price`=?, `comment`=?  WHERE(`ticket`=3)")!=SQLITE_DONE)
     {
      Print("+++++sdf++",sql3.ErrorMsg());
      return;
     }
*/
//--- 6. How to get data from table
   if(sql3.Query(tbl,"SELECT * FROM `Trades`")!=SQLITE_DONE)
     {
      Print("**********",sql3.ErrorMsg());
      return;
     }
   Print(TablePrint(tbl)); // printed in Experts log
/*
//--- 7. How to delete all rows from table
   if(sql3.Query("DELETE FROM `Trades`")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return;
     }

//--- 8. How to get names of all tables in database
   if(sql3.Query(tbl,"SELECT `name` FROM `sqlite_master` WHERE `type`='table' ORDER BY `name`;")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return;
     }
   Print(TablePrint(tbl));

//--- 9. How to delete a table
   sql3.Query("DROP TABLE IF EXISTS `Trades`");

//--- 10. How to compress a database
   sql3.Query("VACUUM");
   */
  }
//+------------------------------------------------------------------+
//| Comment Table                                                    |
//+------------------------------------------------------------------+
string TablePrint(CSQLite3Table &tbl)
  {
  Print("start to print");
   string str="";
   int cs=ArraySize(tbl.m_colname);
   for(int c=0; c<cs; c++)
      str+=tbl.m_colname[c]+" | ";
   str+="\n";

   int rs=ArraySize(tbl.m_data);
   for(int r=0; r<rs; r++)
     {
      str+=string(r)+": ";
      CSQLite3Row *row=tbl.Row(r);
      if(CheckPointer(row)==POINTER_INVALID)
        {
         str+="----error row----\n";
         continue;
        }
      cs=ArraySize(row.m_data);
      for(int c=0; c<cs; c++)
         str+=string(row.m_data[c].GetString())+" | ";
      str+="\n";
     }
   return(str);
  }
//+------------------------------------------------------------------+