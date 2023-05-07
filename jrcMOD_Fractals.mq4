//+------------------------------------------------------------------+
//|                                     Fractals - adjustable period |
//+------------------------------------------------------------------+
#property link      "www.forex-tsd.com"
#property copyright "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  Yellow
#property indicator_color2  Yellow
#property indicator_width1  3
#property indicator_width2  3

//
//
//
//
//

extern int    FractalPeriod          = 50;
extern bool   alertsOn               = false;
extern bool   alertsMessage          = true;
extern bool   alertsSound            = false;
extern bool   alertsEmail            = false;
extern int    fSymbol                = 159;
extern double UpperArrowDisplacement = 0.5;
extern double LowerArrowDisplacement = 0.5;

double UpperBuffer[];
double LowerBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   if (MathMod(FractalPeriod,2)==0)
         FractalPeriod = FractalPeriod+1;
   SetIndexBuffer(0,UpperBuffer); SetIndexStyle(0,DRAW_ARROW, EMPTY, 0.5); SetIndexArrow(0, fSymbol);
   SetIndexBuffer(1,LowerBuffer); SetIndexStyle(1,DRAW_ARROW, EMPTY, 0.5); SetIndexArrow(1, fSymbol);
}
int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int half = FractalPeriod/2;
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(MathMax(Bars-counted_bars,FractalPeriod),Bars-1);

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--)
   {
         bool   found     = true;
         double compareTo = High[i];
         for (int k=1;k<=half;k++)
            {
               if ((i+k)<Bars && High[i+k]> compareTo) { found=false; break; }
               if ((i-k)>=0   && High[i-k]>=compareTo) { found=false; break; }
            }
         if (found) 
               UpperBuffer[i]=High[i]+iATR(NULL,0,20,i)*UpperArrowDisplacement;
         else  UpperBuffer[i]=EMPTY_VALUE;

      //
      //
      //
      //
      //
      
         found     = true;
         compareTo = Low[i];
         for (k=1;k<=half;k++)
            {
               if ((i+k)<Bars && Low[i+k]< compareTo) { found=false; break; }
               if ((i-k)>=0   && Low[i-k]<=compareTo) { found=false; break; }
            }
         if (found)
              LowerBuffer[i]=Low[i]-iATR(NULL,0,20,i)*LowerArrowDisplacement;
         else LowerBuffer[i]=EMPTY_VALUE;
   }
 
 
   //
   //
   //
   //
   //
   
   static datetime previousLevel = -1; static int previousSignal = 0;
   
   if (alertsOn)
   {
      int currentBar=-1;
               for (i=0; i<Bars-1; i++) if (LowerBuffer[i]!=EMPTY_VALUE || UpperBuffer[i]!=EMPTY_VALUE) { currentBar = i; break; }
      if (currentBar>-1) checkAlert(currentBar,previousLevel,previousSignal,UpperBuffer,LowerBuffer ,"");
   }

   //
   //
   //
   //
   //
   
   return(0);
}

//+------------------------------------------------------------------+
//|                                                             
//+------------------------------------------------------------------+
//
//
//
//
//

void checkAlert(int currentBar, datetime& previousLevel, int& previousSignal, double& upBuffer[], double& dnBuffer[], string text)
{
   int previousBar = iBarShift(NULL,0,previousLevel);
   int currentSignal;
         if (upBuffer[currentBar]!=EMPTY_VALUE)                                      currentSignal = -1;
         if (dnBuffer[currentBar]!=EMPTY_VALUE)                                      currentSignal =  1;
         if (dnBuffer[currentBar]!=EMPTY_VALUE && upBuffer[currentBar]!=EMPTY_VALUE) currentSignal =  0;

   //
   //
   //
   //
   //
   
   if (currentBar != previousBar || currentSignal != previousSignal)
   {
      if (currentSignal != previousSignal && currentBar > previousBar && previousLevel != -1)
            string alertText = "reverted to ";
      else         alertText = "current signal ";            
      switch(currentSignal)
      {
         case  0 : doAlert(text+alertText+"up/down"); break;
         case  1 : doAlert(text+alertText+"up");      break;
         case -1 : doAlert(text+alertText+"down");
      }               
 
      //
      //
      //
      //
      //
              
      previousLevel  = Time[currentBar];
      previousSignal = currentSignal;
   }
}

//
//
//
//
//

void doAlert(string doWhat)
{
   string message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Fractals ",doWhat);
      if (alertsMessage) Alert(message);
      if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Fractals"),message);
      if (alertsSound)   PlaySound("alert2.wav");
}