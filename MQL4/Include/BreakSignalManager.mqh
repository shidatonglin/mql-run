
#include <BreakSignal.mqh>
#include <MQH\Lib\SQLite3\SQLite3Base.mqh>

string pairs[] = {"EURUSD","USDJPY","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF"
                ,"EURJPY","AUDJPY","GBPJPY","NZDJPY","CADJPY","AUDCAD","AUDNZD"
                ,"EURCAD","EURAUD","NZDCAD"
                ,"Gold"
                ,"JP225Cash","HK50Cash","CHI50Cash"
                ,"EU50Cash","FRA40Cash","GER30Cash","UK100Cash"
                ,"US100Cash","US30Cash","US500Cash"};

struct ExpertSignal{

   string   m_symbol;
   int      m_timeFrame;
   datetime m_dateTime;
   string   m_signalName;
   string   m_signalType;

   ExpertSignal(string symbol, int timeframe, datetime dateTime, string signalName, string signalType){
      this.m_symbol = symbol;
      this.m_timeFrame = timeframe;
      this.m_dateTime = dateTime;
      this.m_signalName = signalName;
      this.m_signalType = signalType;
   }
};


class SignalManager{

private:
public:
    SignalManager();
    ~SignalManager();
    void CheckSignal();
    void SendMassage(string);
    void InsertSignal(const ExpertSignal&);
};

SignalManager::SignalManager(){}

SignalManager::~SignalManager(){}

void SignalManager::CheckSignal(){

    int size = ArraySize(pairs);
    BreakSignal experts[30];
    //Print("Total trade pairs:" ,size);
    for(int i=0; i<size;i++){
        experts[i].Init(pairs[i], PERIOD_H4);
    }

    static int pretime = 0;
    int signal = 0;
    string message = "";
    if(pretime != Time[0]){
        for(int i=0;i<size;i++){
            signal = experts[i].GetSignal();
            if(signal != 0){
            //Symbol(),Period(),Time[0],"BreakSignal","Buy"
               ExpertSignal eSignal(experts[i].Symbol(),experts[i].TimeFrame(),Time[0]
                              ,"BreakSignal", (signal==1 ? "Buy" : "Sell"));
               InsertSignal(eSignal);
                message = (experts[i].Symbol()) +  " Signal -->" +  (signal==1 ? "Buy" : "Sell");
                //SendMassage(message);
                //SendNotification(message);
                //SendMail("Signal Notifications", message);
            } else {
               //message = (experts[i].Symbol()) +  " Signal -->" + signal;
            }
            //SendMassage(message);
        }
        pretime = Time[0];
    }
}

void SignalManager::SendMassage(string message){
   SendNotification(message);
   SendMail("Signal Notifications", message);
}

void SignalManager::InsertSignal(const ExpertSignal &expertSignal){
   CSQLite3Base sql3;
   string fileName = TerminalInfoString(TERMINAL_DATA_PATH) 
                     + "\\MQL4\\Files\\SQLite\\Expert.db3" ;
   if(sql3.Connect(fileName)!=SQLITE_OK)
      return;
   CSQLite3Row row;
   row.Add(expertSignal.m_symbol);
   row.Add(expertSignal.m_timeFrame);
   row.Add(TimeToString(expertSignal.m_dateTime));
   row.Add(expertSignal.m_signalType);
   row.Add(expertSignal.m_signalName);
   
   if(sql3.QueryBind(row,"INSERT INTO `SignalHistory` VALUES(?,?,?,?,?)")!=SQLITE_DONE)
     {
      Print("+++++sdf++",sql3.ErrorMsg());
      return;
     }
    sql3.Disconnect();
}


