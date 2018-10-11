2014-02-12, Xaphod

Installation:

1. Copy the following files to your metatrader data folder - '../Metatrader4/MQL4/indicators/'
   (To locate your metatrader data folder use 'Top Menu -> File -> Open Data Folder'):
    GMTS-Matrix.mq4
    GMTS-Tape.mq4
    GMTS-Dash.ex4
    TVI.mq4
    T3MA-Basic.mq4
    GannHiLo-Histo.mq4

2. Restart MT4.

3. Double click to load or Drag and drop the GMTS-Matrix/GMTS-Tape/GMTS-Dash indicator on to your chart.

Note:
These indicators require that the following indicators are installed and working:
  TVI.mq4, GannHiLo-Histo.mq4, T3MA-Basic.mq4       

Troubleshooting:
  • Check the 'Journal' and 'Expert' tabs in the terminal window for errors.
  • If you have installed the indicators and MT4 cannot find them, the cause may be windows Vista/7/8 file virtualization. 
    Solutions: Install MT4 outside the Program Files folder or give your user full read/write rights to the MT4 folders.
_______________________________________________________________________________

GMTS-Matrix:

GMTS-Matrix is a non-repainting matrix indicator for use with the ‘Genesis Matrix Trading System’.
  • It is composed of the following indicators:
    1. TVI
    2. CCI
    3. Gann High/Low Indicator
    4. T3 Moving Average
  • Multi time-frame. All bars in the chart corresponding to a higher time-frame bar will be updated 
to reflect the current state of the higher time-frame indicator.
  • Optional alert when all 4 indicators line up.
  • Set labels of your choice.

Indicator Parameters

TimeFrame_Settings
  TimeFrame_Period=0                Timeframe: 0,1,5,15,30,60,240,1440 etc. Current Timeframe=0. 
  TimeFrame_Auto=0                  Automatically select higher TF. M15 and M30 -> H1. Off=0, 1st HigherTF=1, 2nd HigherTF=2.
  TimeFrame_Divider_MaxLines=30     Draw period divider line for higher time-frame bars. Nr of bars back. Set to 0 to disable.
  TimeFrame_Divider_Color=DarkGray  Color of period divider lines.

TVI_Settings
  TVI_r=12                          TVI r Period.
  TVI_s=12                          TVI s Period.
  TVI_u=5                           TVI u Period.
  TVI_Label="TVI"                   Label for the TVI signal line.

CCI_Settings
  CCI_Period=20                     CCI Period.
  CCI_Label="CCI"                   Label for the CCI signal line.

GannHiLo_Settings
  GannHiLo_Period=10                Gann High/Low Period.
  GannHiLo_Label=GHL                Label for the GannHiLo signal line.

T3MA_Settings
  T3MA_Period=8                     T3MA Period.
  T3MA_b=0.618                      Volume factor.
  T3MA_MaxBars=500                  Maximum number of bars to draw. Set to 0 to show the full history.
  T3MA_Label=GM                     Label for the T3MA  signal line.

Alert_Settings
  Alert_OnBarClose=True             Alert only when an open bar closes.
  Alert_Popup=False                 Popup window & sound on Alert_
  Alert_Sound=                      Play sound on Alert. Wav files only.
  Alert_Email=False                 Send email on Alert.
  Alert_Subject=                    Email subject. Null string ("") will result in a preconfigured subject.

Label_Settings
  Label_Color=White                 Color of Histogram Id labels.

_______________________________________________________________________________

GMTS Tape:

GMTS-Tape is a tape chart of the ‘Genesis Matrix Trading System’ Matrix indicator.
  • It is composed of the following indicators:
     1. TVI
     2. CCI
     3. T3 Moving Average
     4. Gann High/Low Indicator 
  • Multi time-frame. All bars in the chart corresponding to a higher time-frame bar will be updated to reflect the current state of the higher time-frame indicator.
  • Optional alert when all the signal changes. 
 

Indicator Parameters:

TimeFrame_Settings
  TimeFrame_Period=0                    Timeframe: 0,1,5,15,30,60,240,1440 etc. Current Timeframe=0. 
  TimeFrame_Auto=0                      Automatically select higher TF. M15 and M30 -> H1. Off=0, 1st HigherTF=1, 2nd HigherTF=2
  TimeFrame_Divider_MaxLines=30;        Draw period divider line for higher time-frame bars. Nr of bars back. Set to 0 to disable.
  TimeFrame_Divider_Color=DarkGray      Color of period divider lines.

Mode_Settings
  Mode_Show3Bars=False                  Indicate when 3 of 4 bars are the same.
  Mode_NoSigColor=DimGray               Color of no signal bar for 4 bars Mode.
  Mode_3UpColor=RoyalBlue               Color of up signal bar for 3 of 4 bars.
  Mode_3DownColor=FireBrick             Color of down signal bar for 3 of 4 bars.

TVI_Settings
  TVI_r=12                              TVI r Period.
  TVI_s=12                              TVI s Period.
  TVI_u=5                               TVI u Period.

CCI_Settings
  CCI_Period=20                         CCI Period.

GannHiLo_Settings
  GannHiLo_Period=10                    Gann High/Low Period.

T3MA_Settings
  T3MA_Period=8                         T3MA Period.
  T3MA_b=0.618                          Volume factor.
  T3MA_MaxBars=500                      Maximum number of bars to draw. Set to 0 to show the full history.

Alert_Settings
  Alert_3Bars=False                     Alert when 3 bars line up.
  Alert_4Bars=False                     Alert when 4 bars line up.
  Alert_OnBarClose=True                 Alert only when an open bar closes.
  Alert_Popup=False                     Popup window & sound on Alert.
  Alert_Sound=                          Play sound on Alert_ Wav files only.
  Alert_Email=False                     Send email on Alert.
  Alert_Subject=                        Email subject. Null string ("") will result in a preconfigured subject.

_______________________________________________________________________________

GMTS-Dash

GMTS-Dash is a signal dashboard for the ‘Genesis Matrix Trading System’. It displays the 
current matrix signals for multiple time-frames and the ADR.
  • It is composed of the following indicators:
     1. TVI
     2. CCI
     3. T3 Moving Average
     4. Gann High/Low Indicator
  • Display 1 to 6 time-frames of the current GMTS signals.
  • Show optional ADR level calculated from daily candles.
  • 2 Optional alerts that can be set to alert when specified time-frames line up. 
  • User configurable colors.
  • 5 different arrow types.
  • Position relative to the on top-left or top right corner. Positioning on the top left corner. Requires that the use of dlls is enabled.

NOTE!
  GMTS-Dash REQUIRES MT4 Build 600 or newer. 
  If it crashes your copy of MT4, delete it from the indicators folder and restart MT4.


Indicator Parameters

TimeFrame_Settings
  TimeFrame_1=M1                Timeframe: M1,M5,M15,M30;H1,H4,D1,W1,MN1 or 1,5,15,30,60,240,1440,10080,43200. Do not display: 0 or NULL String.
  TimeFrame_2=M5 
  TimeFrame_3=M15 
  TimeFrame_4=H1 
  TimeFrame_5=H4
  TimeFrame_6=D1
  TimeFrame_TF1BarNr=0          Bar nr to display data for. 'Currently open bar'=0, 'Last closed bar'=1.
  TimeFrame_TF2BarNr=0
  TimeFrame_TF3BarNr=0
  TimeFrame_TF4BarNr=0
  TimeFrame_TF5BarNr=0
  TimeFrame_TF6BarNr=0

TVI_Settings
  TVI_r=12 TVI                  r Period.
  TVI_s=12 TVI                  s Period.
  TVI_u=5 TVI                   u Period.
  TVI_Label=TVI                 Label for TVI signal line.

CCI_Settings
  CCI_Period=20                 CCI Period.
  CCI_Label="CCI"               Label for CCI signal line.

T3MA_Settings
  T3MA_Period=8                 T3MA Period.
  T3MA_b=0.618                  Volume factor.
  T3MA_Label="T3 "              Label for the T3MA  signal line.

GannHiLo_Settings
  GannHiLo_Period=10            Gann High/Low Period.
  GannHiLo_Label="GHL"          Label for the GannHiLo signal line.

ADR_Settings
  ADR_Enable=True               Enable ADR Display.
  ADR_Days=20                   Nr of days to use for calculation.
  ADR_Low=40 ADR                Low level in percent.
  ADR_High=90 ADR               High level in percent.
  ADR_BarSize=10                Size of each bar in the ADR bar graph.
  ADR_BarScale=5.0              Scale factor. Adjust if there are gaps or overlapping of bar-graph sections.
  ADR_BarMaxLen=26              Maximum length of the bar-garph. Adjust if the bar-graph is too long or short.
  ADR_BarYOffset=3              Y offset of bar the ADR bar-graph.
  ADR_TextSize=9                ADR Value text size.
  ADR_TextYOffset=7             ADR Value text y-offset.

Alert_Settings
  Alert_Set1=110000             Alert flags for TF1, TF2, TF3, TF4, TF5, TF6. Enable=1, Disable=0. Ex: 010100=TF2 AND TF4.
  Alert_Set2=101000             Alert flags for TF1, TF2, TF3, TF4. Enable=1, Disable=0. Ex: 101000=TF1 AND TF3.
  Alert_OnBarClose=True         Alert only when an open bar closes.
  Alert_Popup=True              Popup window & sound on Alert_
  Alert_Sound=                  Play sound on Alert. Wav files only.
  Alert_Email=False             Send email on Alert.
  Alert_Subject=                Email Subject. Blank will result in a preconfigured subject.

Display_Settings
  Display_X=5 			X position of Display.
  Display_Y=15                  Y position of Display.
  Display_Corner=0              Display corner. Top left=0, Top Right=1.
  Display_Window=0              Window to display the dashboard in.
  Display_SysFontSize=1.0       Display system font size zoom factor. Normal=1.0, 125% zoom=1.25.
  Display_ColorBkg1=Gray        Background color for odd line.
  Display_ColorBkg2=Gray        Background color for even line.
  Display_ColorHeader=Gold      Color of the header text.
  Display_ColorSignal=Blue      Color of the symbol text.
  Display_ColorUp=Green         Color of the up signal.
  Display_ColorDown=Red         Color of the down signal.
  Display_ArrowType=0           0=Arrow, 1=Diagonal Arrow, 2=Square, 3=Dot, 4=Diamond.