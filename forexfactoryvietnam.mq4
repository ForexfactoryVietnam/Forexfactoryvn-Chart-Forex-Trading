//+------------------------------------------------------------------+
//|                                          forexfactoryvietnam.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                      https://forexfactoryvn.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
//---- input parameters
extern bool Alerts = false;
extern int  GMTshift=0;
extern bool Pivot = true;
extern color PivotColor = Yellow;
extern color PivotFontColor = White;
extern int PivotFontSize = 8;
extern int PivotWidth = 1;
extern int PipDistance = 20;
extern color CamFontColor = White;
extern int CamFontSize = 10;
extern bool Fibs = false;
extern color FibColor = Sienna;
extern color FibFontColor = White;
extern int FibFontSize = 8;
extern bool StandardPivots = false;
extern color StandardFontColor = White;
extern int StandardFontSize = 8;
extern color SupportColor = White;
extern color ResistanceColor = FireBrick;
extern bool MidPivots = false;
extern color MidPivotColor = White;
extern int MidFontSize = 8;

double P, H3, H4, H5;
double L3, L4, L5;
double LastHigh,LastLow,x;
bool firstL3=true;
bool firstH3=true;

double D1=0.091667;
double D2=0.183333;
double D3=0.2750;
double D4=0.55;


// Fib variables

double yesterday_high=0;
double yesterday_low=0;
double yesterday_close=0;
double r3=0;
double r2=0;
double r1=0;
double p=0;
double s1=0;
double s2=0;
double s3=0;
double R;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
if (Fibs)
{ObjectDelete("FibR1 Label"); 
ObjectDelete("FibR1 Line");
ObjectDelete("FibR2 Label");
ObjectDelete("FibR2 Line");
ObjectDelete("FibR3 Label");
ObjectDelete("FibR3 Line");
ObjectDelete("FibS1 Label");
ObjectDelete("FibS1 Line");
ObjectDelete("FibS2 Label");
ObjectDelete("FibS2 Line");
ObjectDelete("FibS3 Label");
ObjectDelete("FibS3 Line");
}
if (Pivot)
{
ObjectDelete("P Label");
ObjectDelete("P Line");
}
ObjectDelete("H5 Label");
ObjectDelete("H5 Line");
ObjectDelete("H4 Label");
ObjectDelete("H4 Line");
ObjectDelete("H3 Label");
ObjectDelete("H3 Line");
ObjectDelete("L3 Label");
ObjectDelete("L3 Line");
ObjectDelete("L4 Label");
ObjectDelete("L4 Line");
ObjectDelete("L5 Label");
ObjectDelete("L5 Line");
//----
if (StandardPivots)
{
ObjectDelete("R1 Label"); 
ObjectDelete("R1 Line");
ObjectDelete("R2 Label");
ObjectDelete("R2 Line");
ObjectDelete("R3 Label");
ObjectDelete("R3 Line");
ObjectDelete("S1 Label");
ObjectDelete("S1 Line");
ObjectDelete("S2 Label");
ObjectDelete("S2 Line");
ObjectDelete("S3 Label");
ObjectDelete("S3 Line");
}
if (MidPivots)
{
ObjectDelete("M5 Label");
ObjectDelete("M5 Line");
ObjectDelete("M4 Label");
ObjectDelete("M4 Line");
ObjectDelete("M3 Label");
ObjectDelete("M3 Line");
ObjectDelete("M2 Label");
ObjectDelete("M2 Line");
ObjectDelete("M1 Label");
ObjectDelete("M1 Line");
ObjectDelete("M0 Label");
ObjectDelete("M0 Line");

}
   return(0);
  }

int DoAlerts()
{
   double DifAboveL3,PipsLimit;
   double DifBelowH3;

   DifBelowH3 = H3 - Close[0];
   DifAboveL3 = Close[0] - L3;
   PipsLimit = PipDistance*Point;
   
   if (DifBelowH3 > PipsLimit) firstH3 = true;
   if (DifBelowH3 <= PipsLimit && DifBelowH3 > 0)
   {
    if (firstH3)
    {
      Alert("Below Cam H3 Line by ",DifBelowH3, " for ", Symbol(),"-",Period());
      PlaySound("alert.wav");
      firstH3=false;
    }
   }

   if (DifAboveL3 > PipsLimit) firstL3 = true;
   if (DifAboveL3 <= PipsLimit && DifAboveL3 > 0)
   {
    if (firstL3)
    {
      Alert("Above Cam L3 Line by ",DifAboveL3," for ", Symbol(),"-",Period());
      Sleep(2000);
      PlaySound("timeout.wav");
      firstL3=false;
    }
   }
   
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//---- TODO: add your code here
double day_high=0;
double day_low=0;
double yesterday_open=0;
double today_open=0;
double Q=0,S=0,R=0,M2=0,M3=0,S1=0,R1=0,M1=0,M4=0,S2=0,R2=0,M0=0,M5=0,S3=0,R3=0,nQ=0,nD=0,D=0;

int cnt=720;
double cur_day=0;
double prev_day=0;

double rates_d1[2][6];

//---- exit if period is greater than daily charts
if(Period() > 1440)
{
Print("Error - Chart period is greater than 1 day.");
return(-1); // then exit
}

//---- Get new daily prices & calculate pivots

while (cnt!= 0)
{
	cur_day = TimeDay(Time[cnt]- (GMTshift*3600));
	
	if (prev_day != cur_day)
	{
		yesterday_close = Close[cnt+1];
		today_open = Open[cnt];
		yesterday_high = day_high;
		yesterday_low = day_low;

		day_high = High[cnt];
		day_low  = Low[cnt];

		prev_day = cur_day;
	}
   
   if (High[cnt]>day_high)
   {
      day_high = High[cnt];
   }
   if (Low[cnt]<day_low)
   {
      day_low = Low[cnt];
   }
	
	cnt--;

}



D = (day_high - day_low);
Q = (yesterday_high - yesterday_low);
//------ Pivot Points ------

P = (yesterday_high + yesterday_low + yesterday_close)/3;//Pivot
//---- To display all 8 Camarilla pivots remove comment symbols below and
// add the appropriate object functions below
H5 = (yesterday_high/yesterday_low)*yesterday_close;
H4 = ((yesterday_high - yesterday_low)* D4) + yesterday_close;
H3 = ((yesterday_high - yesterday_low)* D3) + yesterday_close;
//H2 = ((yesterday_high - yesterday_low) * D2) + yesterday_close;
//H1 = ((yesterday_high - yesterday_low) * D1) + yesterday_close;

//L1 = yesterday_close - ((yesterday_high - yesterday_low)*(D1));
//L2 = yesterday_close - ((yesterday_high - yesterday_low)*(D2));
L3 = yesterday_close - ((yesterday_high - yesterday_low)*(D3));
L4 = yesterday_close - ((yesterday_high - yesterday_low)*(D4));
L5 = yesterday_close - (H5 - yesterday_close);

if (Fibs)
{
      R = yesterday_high - yesterday_low;//range
      p = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
      r1 = p + (R * 0.38);
      r2 = p + (R * 0.62);
      r3 = p + (R * 0.99);
      s1 = p - (R * 0.38);
      s2 = p - (R * 0.62);
      s3 = p - (R * 0.99);
}

if (StandardPivots)
{
R1 = (2*P)-yesterday_low;
S1 = (2*P)-yesterday_high;
R2 = P-S1+R1;
S2 = P-R1+S1;
R3 = (2*P)+(yesterday_high-(2*yesterday_low));
S3 = (2*P)-((2* yesterday_high)-yesterday_low);
}
if (MidPivots)
{
M0 = (S2+S3)/2;
M1 = (S1+S2)/2;
M2 = (P+S1)/2;
M3 = (P+R1)/2;
M4 = (R1+R2)/2;
M5 = (R2+R3)/2;
}

//comment on OHLC and daily range

if (Q > 5) 
{
	nQ = Q;
}
else
{
	nQ = Q*10000;
}

if (D > 5)
{
	nD = D;
}
else
{
	nD = D*10000;
}

 if (StringSubstr(Symbol(),3,3)=="JPY")
      {
      nQ=nQ/100;
      nD=nD/100;
      }

Comment("High= ",yesterday_high,"    Previous Days Range= ",nQ,"\nLow= ",yesterday_low,"    Current Days Range= ",nD,"\nClose= ",yesterday_close);

//---- Set line labels on chart window
 if (Pivot)
   {

      if(ObjectFind("P label") != 0)
      {
      ObjectCreate("P label", OBJ_TEXT, 0, Time[0], P);
      ObjectSetText("P label", "Pivot", PivotFontSize, "Arial", PivotFontColor);
      }
      else
      {
      ObjectMove("P label", 0, Time[0], P);
      }

//---  Draw  Pivot lines on chart

      if(ObjectFind("P line") != 0)
      {
      ObjectCreate("P line", OBJ_HLINE, 0, Time[40], P);
      ObjectSet("P line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("P line", OBJPROP_COLOR, PivotColor);
      }
      else
      {
      ObjectMove("P line", 0, Time[40], P);
      }

  }

  if (StandardPivots)
  {
if(ObjectFind("R1 label") != 0)
      {
      ObjectCreate("R1 label", OBJ_TEXT, 0, Time[0], R1);
      ObjectSetText("R1 label", " R1", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("R1 label", 0, Time[0], R1);
      }

      if(ObjectFind("R2 label") != 0)
      {
      ObjectCreate("R2 label", OBJ_TEXT, 0, Time[20], R2);
      ObjectSetText("R2 label", " R2", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("R2 label", 0, Time[20], R2);
      }

      if(ObjectFind("R3 label") != 0)
      {
      ObjectCreate("R3 label", OBJ_TEXT, 0, Time[20], R3);
      ObjectSetText("R3 label", " R3", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("R3 label", 0, Time[20], R3);
      }

      if(ObjectFind("S1 label") != 0)
      {
      ObjectCreate("S1 label", OBJ_TEXT, 0, Time[0], S1);
      ObjectSetText("S1 label", "S1", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("S1 label", 0, Time[0], S1);
      }

      if(ObjectFind("S2 label") != 0)
      {
      ObjectCreate("S2 label", OBJ_TEXT, 0, Time[20], S2);
      ObjectSetText("S2 label", "S2", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("S2 label", 0, Time[20], S2);
      }

      if(ObjectFind("S3 label") != 0)
      {
      ObjectCreate("S3 label", OBJ_TEXT, 0, Time[20], S3);
      ObjectSetText("S3 label", "S3", StandardFontSize, "Arial", StandardFontColor);
      }
      else
      {
      ObjectMove("S3 label", 0, Time[20], S3);
      }

//---  Draw  Pivot lines on chart
      if(ObjectFind("S1 line") != 0)
      {
      ObjectCreate("S1 line", OBJ_HLINE, 0, Time[40], S1);
      ObjectSet("S1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("S1 line", OBJPROP_COLOR, SupportColor);
      }
      else
      {
      ObjectMove("S1 line", 0, Time[40], S1);
      }

      if(ObjectFind("S2 line") != 0)
      {
      ObjectCreate("S2 line", OBJ_HLINE, 0, Time[40], S2);
      ObjectSet("S2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("S2 line", OBJPROP_COLOR, SupportColor);
      }
      else
      {
      ObjectMove("S2 line", 0, Time[40], S2);
      }

      if(ObjectFind("S3 line") != 0)
      {
      ObjectCreate("S3 line", OBJ_HLINE, 0, Time[40], S3);
      ObjectSet("S3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("S3 line", OBJPROP_COLOR, SupportColor);
      }
      else
      {
      ObjectMove("S3 line", 0, Time[40], S3);
      }

      if(ObjectFind("R1 line") != 0)
      {
      ObjectCreate("R1 line", OBJ_HLINE, 0, Time[40], R1);
      ObjectSet("R1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("R1 line", OBJPROP_COLOR, ResistanceColor);
      }
      else
      {
      ObjectMove("R1 line", 0, Time[40], R1);
      }

      if(ObjectFind("R2 line") != 0)
      {
      ObjectCreate("R2 line", OBJ_HLINE, 0, Time[40], R2);
      ObjectSet("R2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("R2 line", OBJPROP_COLOR, ResistanceColor);
      }
      else
      {
      ObjectMove("R2 line", 0, Time[40], R2);
      }

      if(ObjectFind("R3 line") != 0)
      {
      ObjectCreate("R3 line", OBJ_HLINE, 0, Time[40], R3);
      ObjectSet("R3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("R3 line", OBJPROP_COLOR, ResistanceColor);
      }
      else
      {
      ObjectMove("R3 line", 0, Time[40], R3);
      }
  }
  
  if (MidPivots)
  {
      if(ObjectFind("M5 label") != 0)
      {
      ObjectCreate("M5 label", OBJ_TEXT, 0, Time[20], M5);
      ObjectSetText("M5 label", " M5", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M5 label", 0, Time[20], M5);
      }

      if(ObjectFind("M4 label") != 0)
      {
      ObjectCreate("M4 label", OBJ_TEXT, 0, Time[20], M4);
      ObjectSetText("M4 label", " M4", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M4 label", 0, Time[20], M4);
      }

      if(ObjectFind("M3 label") != 0)
      {
      ObjectCreate("M3 label", OBJ_TEXT, 0, Time[20], M3);
      ObjectSetText("M3 label", " M3", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M3 label", 0, Time[20], M3);
      }

      if(ObjectFind("M2 label") != 0)
      {
      ObjectCreate("M2 label", OBJ_TEXT, 0, Time[20], M2);
      ObjectSetText("M2 label", " M2", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M2 label", 0, Time[20], M2);
      }

      if(ObjectFind("M1 label") != 0)
      {
      ObjectCreate("M1 label", OBJ_TEXT, 0, Time[20], M1);
      ObjectSetText("M1 label", " M1", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M1 label", 0, Time[20], M1);
      }

      if(ObjectFind("M0 label") != 0)
      {
      ObjectCreate("M0 label", OBJ_TEXT, 0, Time[20], M0);
      ObjectSetText("M0 label", " M0", MidFontSize, "Arial", MidPivotColor);
      }
      else
      {
      ObjectMove("M0 label", 0, Time[20], M0);
      }
     

      if(ObjectFind("M5 line") != 0)
      {
      ObjectCreate("M5 line", OBJ_HLINE, 0, Time[40], M5);
      ObjectSet("M5 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M5 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M5 line", 0, Time[40], M5);
      }

      if(ObjectFind("M4 line") != 0)
      {
      ObjectCreate("M4 line", OBJ_HLINE, 0, Time[40], M4);
      ObjectSet("M4 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M4 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M4 line", 0, Time[40], M4);
      }

      if(ObjectFind("M3 line") != 0)
      {
      ObjectCreate("M3 line", OBJ_HLINE, 0, Time[40], M3);
      ObjectSet("M3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M3 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M3 line", 0, Time[40], M3);
      }

      if(ObjectFind("M2 line") != 0)
      {
      ObjectCreate("M2 line", OBJ_HLINE, 0, Time[40], M2);
      ObjectSet("M2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M2 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M2 line", 0, Time[40], M2);
      }

      if(ObjectFind("M1 line") != 0)
      {
      ObjectCreate("M1 line", OBJ_HLINE, 0, Time[40], M1);
      ObjectSet("M1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M1 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M1 line", 0, Time[40], M1);
      }

      if(ObjectFind("M0 line") != 0)
      {
      ObjectCreate("M0 line", OBJ_HLINE, 0, Time[40], M0);
      ObjectSet("M0 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("M0 line", OBJPROP_COLOR, MidPivotColor);
      }
      else
      {
      ObjectMove("M0 line", 0, Time[40], M0);
      }
  }
  
  if (Fibs)
  {
      if(ObjectFind("FibR1 label") != 0)
      {
        ObjectCreate("FibR1 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR1 label", "Fib R1", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR1 label", 0, Time[0], r1);
      }
      if(ObjectFind("FibR2 label") != 0)
      {
        ObjectCreate("FibR2 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR2 label", "Fib R2", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR2 label", 0, Time[0], r2);
      }
      if(ObjectFind("FibR3 label") != 0)
      {
        ObjectCreate("FibR3 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibR3 label", "Fib R3", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibR3 label", 0, Time[0], r3);
      }
      if(ObjectFind("FibS1 label") != 0)
      {
        ObjectCreate("FibS1 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS1 label", "Fib S1", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS1 label", 0, Time[0], s1);
      }
      if(ObjectFind("FibS2 label") != 0)
      {
        ObjectCreate("FibS2 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS2 label", "Fib S2", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS2 label", 0, Time[0], s2);
      }
      if(ObjectFind("FibS3 label") != 0)
      {
        ObjectCreate("FibS3 label", OBJ_TEXT, 0, 0, 0);
        ObjectSetText("FibS3 label", "Fib S3", FibFontSize, "Arial", FibFontColor);
      }
      else
      {
        ObjectMove("FibS3 label", 0, Time[0], s3);
      }

//---- Set lines on chart window

      if(ObjectFind("FibS1 line") != 0)
      {
        ObjectCreate("FibS1 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS1 line", OBJPROP_COLOR, FibColor);
      }
      else
      {
        ObjectMove("FibS1 line", 0, Time[0], s1);
      }
      if(ObjectFind("FibS2 line") != 0)
      {
        ObjectCreate("FibS2 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS2 line", OBJPROP_COLOR, FibColor);
      }
      else
      {
        ObjectMove("FibS2 line", 0, Time[0], s2);
      }
      if(ObjectFind("FibS3 line") != 0)
      {
        ObjectCreate("FibS3 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibS3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibS3 line", OBJPROP_COLOR, FibColor);
      }
      else
      {
        ObjectMove("FibS3 line", 0, Time[0], s3);
      }
      if(ObjectFind("FibR1 line") != 0)
      {
        ObjectCreate("FibR1 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR1 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR1 line", OBJPROP_COLOR, FibColor);
      }
      else
      {
        ObjectMove("FibR1 line", 0, Time[0], r1);
      }
      if(ObjectFind("FibR2 line") != 0)
      {
        ObjectCreate("FibR2 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR2 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR2 line", OBJPROP_COLOR, FibColor);
      }
      else
      {
        ObjectMove("FibR2 line", 0, Time[0], r2);
      }
      if(ObjectFind("FibR3 line") != 0)
      {
        ObjectCreate("FibR3 line", OBJ_HLINE, 0, 0, 0);
        ObjectSet("FibR3 line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
        ObjectSet("FibR3 line", OBJPROP_COLOR, FibColor);
      }
      else
      {
        ObjectMove("FibR3 line", 0, Time[0], r3);
      }

  }


// --- THE CAMARILLA ---
   if(ObjectFind("H5 label") != 0)
      {
      ObjectCreate("H5 label", OBJ_TEXT, 0, Time[20], H5);
      ObjectSetText("H5 label", " H5 LB TARGET", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("H5 label", 0, Time[20], H5);
      }
      
      if(ObjectFind("H4 label") != 0)
      {
      ObjectCreate("H4 label", OBJ_TEXT, 0, Time[20], H4);
      ObjectSetText("H4 label", " H4 LONG BREAKOUT", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("H4 label", 0, Time[20], H4);
      }

      if(ObjectFind("H3 label") != 0)
      {
      ObjectCreate("H3 label", OBJ_TEXT, 0, Time[20], H3);
      ObjectSetText("H3 label", " H3 SHORT", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("H3 label", 0, Time[20], H3);
      }

      if(ObjectFind("L3 label") != 0)
      {
      ObjectCreate("L3 label", OBJ_TEXT, 0, Time[20], L3);
      ObjectSetText("L3 label", " L3 LONG", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("L3 label", 0, Time[20], L3);
      }

      if(ObjectFind("L4 label") != 0)
      {
      ObjectCreate("L4 label", OBJ_TEXT, 0, Time[20], L4);
      ObjectSetText("L4 label", " L4 SHORT BREAKOUT", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("L4 label", 0, Time[20], L4);
      }
      
      if(ObjectFind("L5 label") != 0)
      {
      ObjectCreate("L5 label", OBJ_TEXT, 0, Time[20], L5);
      ObjectSetText("L5 label", " L5 SB TARGET", CamFontSize, "Arial", CamFontColor);
      }
      else
      {
      ObjectMove("L5 label", 0, Time[20], L5);
      }

//---- Draw Camarilla lines on Chart
      if(ObjectFind("H5 line") != 0)
      {
      ObjectCreate("H5 line", OBJ_HLINE, 0, Time[40], H5);
      ObjectSet("H5 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H5 line", OBJPROP_COLOR, SpringGreen);
      ObjectSet("H5 line", OBJPROP_WIDTH, 1);
      }
      else
      {
      ObjectMove("H5 line", 0, Time[40], H5);
      }
      
      if(ObjectFind("H4 line") != 0)
      {
      ObjectCreate("H4 line", OBJ_HLINE, 0, Time[40], H4);
      ObjectSet("H4 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H4 line", OBJPROP_COLOR, SpringGreen);
      ObjectSet("H4 line", OBJPROP_WIDTH, 1);
      }
      else
      {
      ObjectMove("H4 line", 0, Time[40], H4);
      }

      if(ObjectFind("H3 line") != 0)
      {
      ObjectCreate("H3 line", OBJ_HLINE, 0, Time[40], H3);
      ObjectSet("H3 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H3 line", OBJPROP_COLOR, SpringGreen);
      ObjectSet("H3 line", OBJPROP_WIDTH, 2);
      }
      else
      {
      ObjectMove("H3 line", 0, Time[40], H3);
      }

      if(ObjectFind("L3 line") != 0)
      {
      ObjectCreate("L3 line", OBJ_HLINE, 0, Time[40], L3);
      ObjectSet("L3 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("L3 line", OBJPROP_COLOR, Red);
      ObjectSet("L3 line", OBJPROP_WIDTH, 2);
      }
      else
      {
      ObjectMove("L3 line", 0, Time[40], L3);
      }

      if(ObjectFind("L4 line") != 0)
      {
      ObjectCreate("L4 line", OBJ_HLINE, 0, Time[40], L4);
      ObjectSet("L4 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("L4 line", OBJPROP_COLOR, Red);
      ObjectSet("L4 line", OBJPROP_WIDTH, 1);
      }
      else
      {
      ObjectMove("L4 line", 0, Time[40], L4);
      }
      
      if(ObjectFind("L5 line") != 0)
      {
      ObjectCreate("L5 line", OBJ_HLINE, 0, Time[40], L5);
      ObjectSet("L5 line", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("L5 line", OBJPROP_COLOR, Red);
      ObjectSet("L5 line", OBJPROP_WIDTH, 1);
      }
      else
      {
      ObjectMove("L5 line", 0, Time[40], L5);
      }

//---- done
   // Now check for Alert
   
   if (Alerts) DoAlerts();
   
//----
   return(0);
  }
//+------------------------------------------------------------------+