//+------------------------------------------------------------------+
//|                                                   SQLite.mq4.mq4 |
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
   TestConnection();
   InsertList();
  }
//+------------------------------------------------------------------+

string PrintDatePath(){
   Print("Termina Date Path-->",TerminalInfoString(TERMINAL_DATA_PATH));
   return TerminalInfoString(TERMINAL_DATA_PATH);
}

void TestConnection(){
   string fileName = PrintDatePath() + "\\MQL4\\Files\\SQLite\\Expert.db3" ;
   if(sql3.Connect(fileName)!=SQLITE_OK)
      return;
   
}

void CreateTable(){
   // Create the table (CREATE TABLE)
   sql3.Query("CREATE TABLE IF NOT EXISTS `TestQuery` (`ticket` INTEGER, `open_price` DOUBLE, `comment` TEXT)");
}

void EditTable(){
   // Rename the table  (ALTER TABLE  RENAME)
   sql3.Query("ALTER TABLE `TestQuery` RENAME TO `Trades`");
   
   // Add the column (ALTER TABLE  ADD COLUMN)
   sql3.Query("ALTER TABLE `Trades` ADD COLUMN `profit`");
}

void Insert(){
   // Add the row (INSERT INTO)
   sql3.Query("INSERT INTO `Trades` VALUES(3, 1.212, 'info', 1)");
}
void Update(){   
   // Update the row (UPDATE)
   sql3.Query("UPDATE `Trades` SET `open_price`=5.555, `comment`='New price'  WHERE(`ticket`=3)");
}

void DeleteRecord(){
   // Delete all rows from the table (DELETE FROM)
   sql3.Query("DELETE FROM `Trades`");
}

void DeleteTable(){
   // Delete the table (DROP TABLE)
   sql3.Query("DROP TABLE IF EXISTS `Trades`");
   }

// Compact database (VACUUM)
//sql3.Query("VACUUM");

void GetData(){
   // Read data (SELECT)
   CSQLite3Table tbl;
   sql3.Query(tbl, "SELECT * FROM `Trades`");
   
   // Sample calculation of stat. data from the tables (COUNT, MAX, AVG ...)
   sql3.Query(tbl, "SELECT COUNT(*) FROM `Trades` WHERE(`profit`>0)") ;  
   sql3.Query(tbl, "SELECT MAX(`ticket`) FROM `Trades`");
   sql3.Query(tbl, "SELECT SUM(`profit`) AS `sumprof`, AVG(`profit`) AS `avgprof` FROM `Trades`");
   
   // Get the names of all tables in the base
   sql3.Query(tbl, "SELECT `name` FROM `sqlite_master` WHERE `type`='table' ORDER BY `name`;");
}

void InsertRecord(){
   if(sql3.Query("INSERT INTO `SignalHistory` VALUES('EURUSD', 240, 20180902, 1,1000)")!=SQLITE_DONE)
     {
      Print("+++++++",sql3.ErrorMsg());
      return;
     }
     
   CSQLite3Row row;
   row.Add("GBPUSD");
   row.Add(Period());
   row.Add(TimeToString(Time[1]));
   row.Add(-1);
   row.Add(1001);
   
   if(sql3.QueryBind(row,"INSERT INTO `SignalHistory` VALUES(?,?,?,?,?)")!=SQLITE_DONE)
     {
      Print("+++++sdf++",sql3.ErrorMsg());
      return;
     }
}
void InsertList(){

//---
   datetime startTime = TimeLocal();
   Print("Start to insert", TimeToString(TimeLocal()));
   if(sql3.Query("CREATE TABLE IF NOT EXISTS `Deals` (`ticket` INTEGER PRIMARY KEY, `open_price` DOUBLE, `profit` DOUBLE, `comment` TEXT)")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return;
     }

//--- create transaction
   if(sql3.Exec("BEGIN")!=SQLITE_OK)
     {
      Print(sql3.ErrorMsg());
      return;
     }
     /*
   HistorySelect(0,TimeCurrent());
//--- dump all deals from terminal to table 
   for(int i=0; i<HistoryDealsTotal(); i++)
     {
      CSQLite3Row row;
      long ticket=(long)HistoryDealGetTicket(i);
      row.Add(ticket);
      row.Add(HistoryDealGetDouble(ticket, DEAL_PRICE));
      row.Add(HistoryDealGetDouble(ticket, DEAL_PROFIT));
      row.Add(HistoryDealGetString(ticket, DEAL_COMMENT));
      if(sql3.QueryBind(row,"REPLACE INTO `Deals` VALUES("+row.BindStr()+")")!=SQLITE_DONE)
        {
         sql3.Exec("ROLLBACK");
         Print(sql3.ErrorMsg());
         return;
        }
     }
     */
     int total = OrdersHistoryTotal();
     Print("total history , ", total);
     for(int i=0;i<total;i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) continue;
         if(OrderType() > 1) continue;
         CSQLite3Row row;
         long ticket=(long)OrderTicket();
         row.Add(ticket);
         row.Add(TimeToString(OrderOpenTime()));
         row.Add(OrderType());
         row.Add(OrderLots());
         row.Add(OrderSymbol());
         row.Add(OrderOpenPrice());
         row.Add(OrderStopLoss());
         row.Add(OrderTakeProfit());
         row.Add(TimeToString(OrderCloseTime()));
         row.Add(OrderClosePrice());
         row.Add(OrderSwap());
         row.Add(OrderProfit());
         row.Add(OrderComment());
         row.Add(OrderMagicNumber());
         if(sql3.QueryBind(row,"INSERT INTO `Deals` VALUES("+row.BindStr()+")")!=SQLITE_DONE)
           {
            sql3.Exec("ROLLBACK");
            Print(sql3.ErrorMsg());
            return;
           }
        }
//--- end transaction
   if(sql3.Exec("COMMIT")!=SQLITE_OK)
      return;
   datetime endTime = TimeLocal();
   Print("End to insert", TimeToString(TimeLocal()));
   Print("Total seconds , ", endTime-startTime);
//--- get statistical information from table
   CSQLite3Table tbl;
   CSQLite3Cell cell;

   if(sql3.Query(tbl,"SELECT COUNT(*) FROM `Deals` WHERE(`profit`>0)")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return;
     }
   tbl.Cell(0,0,cell);
   Print("Count(*)=",cell.GetInt64());
//---
   if(sql3.Query(tbl,"SELECT SUM(`profit`) AS `sumprof`, AVG(`profit`) AS `avgprof` FROM `Deals`")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return;
     }
   tbl.Cell(0,0,cell);
   Print("SUM(`profit`)=",cell.GetDouble());
   tbl.Cell(0,1,cell);
   Print("AVG(`profit`)=",cell.GetDouble());
}
