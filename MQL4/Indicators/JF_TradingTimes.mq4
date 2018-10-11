#property indicator_chart_window

#property copyright "Copyright (c) 2011, TraderJF"


/* The number of days this indicator will go back to mark trading times on the chart. */
extern int TRADING_TIMES_DAYS           = 5;

/* Activate the time panel showing the trading times as text. */
extern bool SHOW_DAILY_TIME_PANEL       = false;

/* The distance of the time panel to the left of the chart. */
extern int DAILY_TIME_PANEL_POS_X       = 20;

/* The distance of the time panel to the top of the chart. */
extern int DAILY_TIME_PANEL_POS_Y       = 460;

/* The distance between the first letter of the time description and the first number of the clock value on the time panel. */
extern int DAILY_TIME_PANEL_WIDTH       = 100;

/* The distance between two subsequent lines on the time panel. */
extern int DAILY_TIME_PANEL_LINE_DIST   = 8;


/* The size of the font in the panel showing the trading times as text. */
/* If you change this value, you might also have to change the following property
    DAILY_TIME_PANEL_WIDTH

    and perhaps these, too:
    DAILY_TIME_PANEL_POS_Y
    DAILY_TIME_PANEL_LINE_DIST
*/
extern int FONT_SIZE                    = 9;

/* The name of the font in the panel showing the trading times as text. */
extern string FONT_NAME                 = "Arial";

/* The width of the vertical lines marking the trading times in the chart. */
extern int LINE_WIDTH                   = 3;


/* Change the label text for each trading time to whatever description you like best. */
/* This description appears when hovering with the mouse over a trading time line. */
/* Two trading times must not have the same description. */
/* Use the property SHOW_xxx to display or hide each trading time individually. */

extern string EUROPE_OPEN_LABEL         = "Europe Open";
extern string EUROPE_OPEN_TIME          = "07:00";
extern color EUROPE_OPEN_LINE_COLOR     = DarkOrange;
extern color EUROPE_OPEN_TEXT_COLOR     = DarkOrange;
extern bool SHOW_EUROPE_OPEN            = false;

extern string LONDON_OPEN_LABEL         = "London Open";
extern string LONDON_OPEN_TIME          = "10:00";
extern color LONDON_OPEN_LINE_COLOR     = OrangeRed;
extern color LONDON_OPEN_TEXT_COLOR     = OrangeRed;
extern bool SHOW_LONDON_OPEN            = true;

extern string US_OPEN_LABEL             = "US Open";
extern string US_OPEN_TIME              = "15:00";
extern color US_OPEN_LINE_COLOR         = DarkGoldenrod;
extern color US_OPEN_TEXT_COLOR         = DarkGoldenrod;
extern bool SHOW_US_OPEN                = true;

extern string EUROPE_CLOSE_LABEL        = "Europe Close";
extern string EUROPE_CLOSE_TIME         = "17:00";
extern color EUROPE_CLOSE_LINE_COLOR    = Maroon;
extern color EUROPE_CLOSE_TEXT_COLOR    = Maroon;
extern bool SHOW_EUROPE_CLOSE           = false;

extern string SYDNEY_OPEN_LABEL         = "Sydney Open";
extern string SYDNEY_OPEN_TIME          = "01:00";
extern color SYDNEY_OPEN_LINE_COLOR     = DarkGreen;
extern color SYDNEY_OPEN_TEXT_COLOR     = DarkGreen;
extern bool SHOW_SYDNEY_OPEN            = False;

extern string TOKYO_OPEN_LABEL          = "Tokyo Open";
extern string TOKYO_OPEN_TIME           = "03:00";
extern color TOKYO_OPEN_LINE_COLOR      = Chocolate;
extern color TOKYO_OPEN_TEXT_COLOR      = Chocolate;
extern bool SHOW_TOKYO_OPEN             = false;

extern string IMPORTANT_TIME1_LABEL     = "Important Time 1";
extern string IMPORTANT_TIME1_TIME      = "05:00";
extern color IMPORTANT_TIME1_LINE_COLOR = DarkOrchid;
extern color IMPORTANT_TIME1_TEXT_COLOR = DarkOrchid;
extern bool SHOW_IMPORTANT_TIME1        = false;

extern string IMPORTANT_TIME2_LABEL     = "Important Time 2";
extern string IMPORTANT_TIME2_TIME      = "12:00";
extern color IMPORTANT_TIME2_LINE_COLOR = YellowGreen;
extern color IMPORTANT_TIME2_TEXT_COLOR = YellowGreen;
extern bool SHOW_IMPORTANT_TIME2        = false;



int timeCount = 8;
string labels[8];
string times[8];
color lineColors[8];
color textColors[8];
bool visibilities[8];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
    labels[0] = EUROPE_OPEN_LABEL;
    labels[1] = LONDON_OPEN_LABEL;
    labels[2] = US_OPEN_LABEL;
    labels[3] = EUROPE_CLOSE_LABEL;
    labels[4] = SYDNEY_OPEN_LABEL;
    labels[5] = TOKYO_OPEN_LABEL;
    labels[6] = IMPORTANT_TIME1_LABEL;
    labels[7] = IMPORTANT_TIME2_LABEL;

    times[0] = EUROPE_OPEN_TIME;
    times[1] = LONDON_OPEN_TIME;
    times[2] = US_OPEN_TIME;
    times[3] = EUROPE_CLOSE_TIME;
    times[4] = SYDNEY_OPEN_TIME;
    times[5] = TOKYO_OPEN_TIME;
    times[6] = IMPORTANT_TIME1_TIME;
    times[7] = IMPORTANT_TIME2_TIME;

    lineColors[0] = EUROPE_OPEN_LINE_COLOR;
    lineColors[1] = LONDON_OPEN_LINE_COLOR;
    lineColors[2] = US_OPEN_LINE_COLOR;
    lineColors[3] = EUROPE_CLOSE_LINE_COLOR;
    lineColors[4] = SYDNEY_OPEN_LINE_COLOR;
    lineColors[5] = TOKYO_OPEN_LINE_COLOR;
    lineColors[6] = IMPORTANT_TIME1_LINE_COLOR;
    lineColors[7] = IMPORTANT_TIME2_LINE_COLOR;

    textColors[0] = EUROPE_OPEN_TEXT_COLOR;
    textColors[1] = LONDON_OPEN_TEXT_COLOR;
    textColors[2] = US_OPEN_TEXT_COLOR;
    textColors[3] = EUROPE_CLOSE_TEXT_COLOR;
    textColors[4] = SYDNEY_OPEN_TEXT_COLOR;
    textColors[5] = TOKYO_OPEN_TEXT_COLOR;
    textColors[6] = IMPORTANT_TIME1_TEXT_COLOR;
    textColors[7] = IMPORTANT_TIME2_TEXT_COLOR;

    visibilities[0] = SHOW_EUROPE_OPEN;
    visibilities[1] = SHOW_LONDON_OPEN;
    visibilities[2] = SHOW_US_OPEN;
    visibilities[3] = SHOW_EUROPE_CLOSE;
    visibilities[4] = SHOW_SYDNEY_OPEN;
    visibilities[5] = SHOW_TOKYO_OPEN;
    visibilities[6] = SHOW_IMPORTANT_TIME1;
    visibilities[7] = SHOW_IMPORTANT_TIME2;
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
    deleteTimeLines();
    deleteDailyTimePanel();
}

void createTradingTimeLine(string timeName, color lineColor) {
    ObjectCreate(timeName, OBJ_TREND, 0, 0, 0, 0, 0);
    ObjectSet(timeName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(timeName, OBJPROP_WIDTH, LINE_WIDTH);
    ObjectSet(timeName, OBJPROP_COLOR, lineColor);
    ObjectSet(timeName, OBJPROP_BACK, True);
}

void showTradingTimeLine(string timeName, datetime time, string timeText, color lineColor, bool isVisible) {
    if (isVisible) {
        createTradingTimeLine(timeName, lineColor);
        labelTradingTimeLine(time, timeName, timeText);
    }
}


void deleteTimeLines() {
    for (int i = 0; i < TRADING_TIMES_DAYS; i++) {
        for (int j = 0; j < timeCount; j++) {
            ObjectDelete(labels[j] + " " + i);
        }
    }
}


void createTimeLines() {
    datetime time = CurTime();
    for (int i = 0; i < TRADING_TIMES_DAYS; i++) {
        for (int j = 0; j < timeCount; j++) {
            showTradingTimeLine(labels[j] + " " + i, time, times[j], lineColors[j], visibilities[j]);
        }

        time = subtractDay(time);
        while (TimeDayOfWeek(time) > 5) {
            time = subtractDay(time);
        }
    }
}



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
    createTimeLines();
    showDailyTimePanel();
}

void labelTradingTimeLine(datetime time, string timeName, string timeText) {
    datetime t1, t2;
    double p1, p2;
    int b1, b2;

    t1 = StrToTime(TimeToStr(time, TIME_DATE) + " " + timeText);
    t2 = t1;
    b1 = iBarShift(NULL, 0, t1);
    b2 = iBarShift(NULL, 0, t2);
    p1 = High[Highest(NULL, 0, MODE_HIGH, b1 - b2, b2)];
    p2 = Low [Lowest(NULL, 0, MODE_LOW, b1 - b2, b2)];

    ObjectSet(timeName, OBJPROP_TIME1, t1);
    ObjectSet(timeName, OBJPROP_PRICE1, p1);
    ObjectSet(timeName, OBJPROP_TIME2, t2);
    ObjectSet(timeName, OBJPROP_PRICE2, p2);
}


void showTradingTimeOnPanel(int index, string description, string time, color textColor, bool isVisible) {
    if (isVisible) {
        int yDistance = DAILY_TIME_PANEL_POS_Y + index * (FONT_SIZE + DAILY_TIME_PANEL_LINE_DIST);
        string name1 = description;
        createTextObject(name1, yDistance, DAILY_TIME_PANEL_POS_X, 4);
        ObjectSetText(name1, description, FONT_SIZE, FONT_NAME, textColor);

        string name2 = description + " Time";
        createTextObject(name2, yDistance, DAILY_TIME_PANEL_POS_X + DAILY_TIME_PANEL_WIDTH, 4);
        ObjectSetText(name2, time, FONT_SIZE, FONT_NAME, textColor);
    }
}


void showDailyTimePanel() {
    if (SHOW_DAILY_TIME_PANEL) {
        for (int j = 0; j < timeCount; j++) {
            showTradingTimeOnPanel(j, labels[j], times[j], textColors[j], visibilities[j]);
        }
    }
}


void deleteDailyTimePanel() {
    for (int i = 0; i < timeCount; i++) {
        ObjectDelete(labels[i]);
        ObjectDelete(labels[i] + " Time");
    }
}




datetime subtractDay(datetime time) {
    int year = TimeYear(time);
    int month = TimeMonth(time);
    int day = TimeDay(time);
    int hour = TimeHour(time);
    int minute = TimeMinute(time);

    day--;
    if (day == 0) {
        month--;
        if (month == 0) {
            year--;
            month = 12;
        }
        if ((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12)) {
            day = 31;
        }
        if (month == 2) {
            if (MathMod(year, 4) == 0) {
                day = 29;
            }
            else {
                day = 28;
            }
        }
        if ((month == 4) || (month == 6) || (month == 9) || (month == 11)) {
            day = 30;
        }
    }
    return(StrToTime(year + "." + month + "." + day + " " + hour + ":" + minute));
}


void createTextObject(string name, int yDistance, int xDistance, int corner) {
    ObjectDelete(name);
    ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
    ObjectSet(name, OBJPROP_CORNER, corner);
    ObjectSet(name, OBJPROP_XDISTANCE, xDistance);
    ObjectSet(name, OBJPROP_YDISTANCE, yDistance);
    ObjectSet(name, OBJPROP_BACK, True);
}



