#property strict

#include <sqlite.mqh>

bool do_check_table_exists (string db, string table)
{
    int res = sqlite_table_exists (db, table + "");

    if (res < 0) {
        PrintFormat ("Check for table existence failed with code %d", res);
        return (false);
    }

    return (res > 0);
}

void do_exec (string db, string exp)
{
    int res = sqlite_exec (db, exp + "");
    
    if (res != 0)
        PrintFormat ("Expression '%s' failed with code %d", exp, res);
}

int OnInit()
{
    if (!sqlite_init()) {
        return INIT_FAILED;
    }

    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    sqlite_finalize();
}

void OnStart ()
{
    
   test_update1();
    return;
}

void test_update1(){
   string db = "trx.db";
    if (!do_check_table_exists (db, "trx")) {
       Print("DB not existed!!");
       return;
    }
    string updateSql = "update trx set age = 31 where id = 2001";
    
    //do_exec(db, "select * from trx");
    //do_exec(db,"update 'trx' set 'age'=33, 'guest'='New Guest26' WHERE('id'=2001)");
    do_exec(db,"UPDATE `trx` SET `age`=13, `guest`='New Guest28'  WHERE(`id`=2001)");
}

void test_update(){
   string db = "trx.db";
    if (!do_check_table_exists (db, "trx")) {
       Print("DB not existed!!");
       return;
    }
    string updateSql = "update trx set age = ? where id = 2001";
    int cols[1];
    int handle = sqlite_query (db, updateSql, cols);
    if (handle < 0) {
        Print ("Preparing query failed; query=", updateSql, ", error=", -handle);
        return;
    }
    //sqlite_reset (handle);
    sqlite_bind_int(handle, 1,41);
    //sqlite_bind_int64 (handle, 2, 666.0);
    sqlite_free_query (handle);

    handle = sqlite_query (db, "select * from trx", cols);
    Print("After update ---->");
    while (sqlite_next_row (handle) == 1) {
        for (int i = 0; i < cols[0]; i++)
            Print (sqlite_get_col (handle, i));
    }
}

void test(){
   string db = "trx.db";

    string path = sqlite_get_fname (db);
    Print ("Dest DB path: " + path);

    if (!do_check_table_exists (db, "trx")) {
        Print ("DB not exists, create schema");
        do_exec (db,
            "create table trx (" +
            " id integer," +
            " date integer," +
            " guest text," +
            " price real," +
            " age integer)" );
        do_exec (db, "insert into trx (id,date,guest,price,age) values ('1001','1002','gsa','16.20','12')");
    }

    int cols[1];
    int handle = sqlite_query (db, "select * from trx", cols);

    Print("Before insert ---->");
    while (sqlite_next_row (handle) == 1) {
        for (int i = 0; i < cols[0]; i++)
            Print (sqlite_get_col (handle, i));
    }

    string query = "insert into trx (id, date, guest, price, age) values (?, ?, ?, ?, ?)";
    //int cols[1];

    handle = sqlite_query (db, query, cols);
    if (handle < 0) {
        Print ("Preparing query failed; query=", query, ", error=", -handle);
        return;
    }
    int count = 3;
    for (int i = 0; i < count; i++) {
        sqlite_reset (handle);
        sqlite_bind_int(handle, 1,2000+ i);
        sqlite_bind_int64 (handle, 2, iTime (NULL, 0, i));
        sqlite_bind_text (handle, 3, Symbol () + string(i));
        sqlite_bind_double (handle, 4, NormalizeDouble (iOpen (NULL, 0, i), Digits));
        sqlite_bind_double (handle, 5, 20+i);
        sqlite_next_row (handle);
    }

    sqlite_free_query (handle);

    handle = sqlite_query (db, "select * from trx", cols);
    Print("After insert ---->");
    while (sqlite_next_row (handle) == 1) {
        for (int i = 0; i < cols[0]; i++)
            Print (sqlite_get_col (handle, i));
    }

    string updateSql = "update trx set age = ? , price = ? where id = 2001";
    handle = sqlite_query (db, updateSql, cols);
    sqlite_reset (handle);
    sqlite_bind_int(handle, 1,41);
    sqlite_bind_int64 (handle, 2, 666.0);

    sqlite_free_query (handle);

    handle = sqlite_query (db, "select * from trx", cols);
    Print("After update ---->");
    while (sqlite_next_row (handle) == 1) {
        for (int i = 0; i < cols[0]; i++)
            Print (sqlite_get_col (handle, i));
    }
}
