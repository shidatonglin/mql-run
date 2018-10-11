<chart>
id=131810991083613826
symbol=GER30Cash
period=1440
leftpos=1824
digits=2
scale=8
graph=1
fore=0
grid=0
volume=0
scroll=1
shift=1
ohlc=1
one_click=0
one_click_btn=1
askline=0
days=0
descriptions=0
shift_size=22
fixed_pos=0
window_left=114
window_top=114
window_right=1515
window_bottom=659
window_type=3
background_color=0
foreground_color=16449525
barup_color=16760576
bardown_color=255
bullcandle_color=16760576
bearcandle_color=255
chartline_color=65535
volumes_color=3329330
grid_color=10061943
askline_color=255
stops_color=255

<window>
height=238
fixed_height=0
<indicator>
name=main
</indicator>
<indicator>
name=Moving Average
period=5
shift=2
method=1
apply=5
color=65535
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=ASCTrend1i
flags=275
window_num=0
<inputs>
Risk=6
BarCount=0
</inputs>
</expert>
shift_0=0
draw_0=3
color_0=16711935
style_0=0
weight_0=1
arrow_0=234
shift_1=0
draw_1=3
color_1=65535
style_1=0
weight_1=1
arrow_1=233
shift_2=0
draw_2=12
color_2=0
style_2=0
weight_2=0
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=93
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=PakuAK_Marblez
flags=275
window_num=3
<inputs>
FastLen=12
SlowLen=26
Length=10
StDv=1.0
</inputs>
</expert>
shift_0=0
draw_0=3
color_0=3329330
style_0=0
weight_0=0
arrow_0=108
shift_1=0
draw_1=3
color_1=255
style_1=0
weight_1=0
arrow_1=108
shift_2=0
draw_2=0
color_2=3329330
style_2=0
weight_2=1
shift_3=0
draw_3=0
color_3=255
style_3=0
weight_3=1
levels_color=12632256
levels_style=2
levels_weight=1
level_0=0.00000000
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=69
fixed_height=0
<indicator>
name=Stochastic Oscillator
kperiod=11
dperiod=3
slowing=3
method=0
apply=0
color=32768
style=0
weight=2
color2=255
style2=0
weight2=2
min=0.00000000
max=100.00000000
levels_color=12632256
levels_style=2
levels_weight=1
level_0=20.00000000
level_1=80.00000000
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=34
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=GenesisMatrix 2.22
flags=275
window_num=3
<inputs>
TimeFrame_Settings=覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
TimeFrame_Period=0
TimeFrame_Auto=0
TVI_Settings=覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
TVI_r=12
TVI_s=12
TVI_u=5
TVI_Label=TVI
CCI_Settings=覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
CCI_Period=20
CCI_Threshold=60.0
CCI_Label=CCI
T3_Settings=覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
T3_Period=8
T3_BarCount=1500
T3_Label=T3..
GannHiLo_Settings=覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
GannHiLo_Period=10
GannHiLo_Label=GHL
Alert_Settings=覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
Alert_OnBarClose=true
Alert_Popup=false
Alert_Email=false
Alert_Subject=
Display_Settings=覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
Display_LabelColor=16777215
</inputs>
</expert>
shift_0=0
draw_0=3
color_0=16777215
style_0=0
weight_0=0
arrow_0=110
shift_1=0
draw_1=3
color_1=255
style_1=0
weight_1=0
arrow_1=110
shift_2=0
draw_2=3
color_2=16777215
style_2=0
weight_2=0
arrow_2=110
shift_3=0
draw_3=3
color_3=255
style_3=0
weight_3=0
arrow_3=110
shift_4=0
draw_4=3
color_4=16777215
style_4=0
weight_4=0
arrow_4=110
shift_5=0
draw_5=3
color_5=255
style_5=0
weight_5=0
arrow_5=110
shift_6=0
draw_6=3
color_6=16777215
style_6=0
weight_6=0
arrow_6=110
shift_7=0
draw_7=3
color_7=255
style_7=0
weight_7=0
arrow_7=110
min=0.00000000
max=2.30000000
period_flags=0
show_data=1
<object>
type=21
object_name=Genesis 2.22(D1)_TVI
period_flags=0
create_time=1530973163
description=TVI
color=16777215
font=Calibri
fontsize=8
angle=0
anchor_pos=7
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=1536796800
value_0=2.100000
</object>
<object>
type=21
object_name=Genesis 2.22(D1)_CCI
period_flags=0
create_time=1530973163
description=CCI
color=16777215
font=Calibri
fontsize=8
angle=0
anchor_pos=7
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=1536796800
value_0=1.600000
</object>
<object>
type=21
object_name=Genesis 2.22(D1)_T3..
period_flags=0
create_time=1530973163
description=T3..
color=16777215
font=Calibri
fontsize=8
angle=0
anchor_pos=7
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=1536796800
value_0=1.100000
</object>
<object>
type=21
object_name=Genesis 2.22(D1)_GHL
period_flags=0
create_time=1530973163
description=GHL
color=16777215
font=Calibri
fontsize=8
angle=0
anchor_pos=7
background=0
filling=0
selectable=1
hidden=0
zorder=0
time_0=1536796800
value_0=0.600000
</object>
</indicator>
</window>

<window>
height=50
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=Laguerre-ACS1
flags=275
window_num=4
<inputs>
gamma=0.6
MaxBars=1000
MA=2
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=36095
style_0=0
weight_0=2
shift_1=0
draw_1=12
color_1=0
style_1=0
weight_1=0
min=0.00000000
max=1.00000000
levels_color=12632256
levels_style=2
levels_weight=1
level_0=0.85000002
level_1=0.50000000
level_2=0.15000001
period_flags=0
show_data=1
</indicator>
</window>
</chart>

