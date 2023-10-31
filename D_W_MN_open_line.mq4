 
//*
#property copyright "(c) 2014 by Mop"
#property link      "http://www.forexfactoryvn.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 DodgerBlue
#property indicator_style1 1
#property indicator_style2 1
#property indicator_style3 1
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2


double MonthOpenBuffer[];
double WeekOpenBuffer[];
double DayOpenBuffer[];

double Shft = 0; // 0 = for present daily / week / month open

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	SetIndexStyle(0,DRAW_LINE);
	SetIndexBuffer(0,MonthOpenBuffer);
	SetIndexLabel(0,"MonthOpen");
	SetIndexStyle(1,DRAW_LINE);
	SetIndexBuffer(1,WeekOpenBuffer);
	SetIndexLabel(1,"WeekOpen");
	SetIndexStyle(2,DRAW_LINE);
	SetIndexBuffer(2,DayOpenBuffer);
	SetIndexLabel(2,"DayOpen");
	
		
	return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
	return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int i=0;
   datetime TimeArray2[];
   datetime TimeArray3[];
   datetime TimeArray4[];
   
   int    limit,y2=0,y3=0,y4=0,y5=0;

// Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray2,MODE_TIME,Symbol(),PERIOD_MN1);
   ArrayCopySeries(TimeArray3,MODE_TIME,Symbol(),PERIOD_W1);
   ArrayCopySeries(TimeArray4,MODE_TIME,Symbol(),PERIOD_D1);

   
   limit=100+PERIOD_MN1/Period();
if (NewBar(Period()))
{
   for(i=0,y2=0,y3=0,y4=0;i<limit;i++)

     {
      if(Time[i]<TimeArray2[y2]) y2++;
       MonthOpenBuffer[i]=iOpen(Symbol(),43200,y2+Shft);
       if(Time[i]<TimeArray3[y3]) y3++;
       WeekOpenBuffer[i]=iOpen(Symbol(),10080,y3+Shft);
       if(Time[i]<TimeArray4[y4]) y4++;
       DayOpenBuffer[i]=iOpen(Symbol(),1440,y4+Shft);
       }
       }
   return (0);
}
bool NewBar(int TimeFrame)
  {
   static datetime LastTime=0;
   if(iTime(NULL,TimeFrame,0)!=LastTime)
     {
      LastTime=iTime(NULL,TimeFrame,0);
      return (true);
     }
   else
      return (false);
  }
