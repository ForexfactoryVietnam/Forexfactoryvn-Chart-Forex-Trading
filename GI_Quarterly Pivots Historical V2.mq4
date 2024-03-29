//+------------------------------------------------------------------+
//|                            GI_Quarterly Pivots Historical V2.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#property copyright "Frogvu"
#property link      "forexfactoryvn.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 White  // QR3
#property indicator_color2 Aqua  // QR2
#property indicator_color3 Orange  // QR1
#property indicator_color4 White  // QP
#property indicator_color5 Blue  // QS1
#property indicator_color6 Red  // QS2
#property indicator_color7 Yellow  // QS3


/*#property indicator_buffers 7
#property indicator_color1 Magenta // QP
#property indicator_color2 White //QSI
#property indicator_color3 Crimson //QR1
#property indicator_color4 Aqua //QS2
#property indicator_color5 Crimson //QR2
#property indicator_color6 DodgerBlue //QS23
#property indicator_color7 Crimson // QR3*/
#property indicator_width4 5

int fontsize =8;
//---- input parameters


//---- buffers
double QRes3[];
double QRes2[];
double QRes1[];
double QPivot[];
double QSupp1[];
double QSupp2[];
double QSupp3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

   SetIndexBuffer(0,QRes3);
   SetIndexBuffer(1,QRes2);
   SetIndexBuffer(2,QRes1);
   SetIndexBuffer(3,QPivot);
   SetIndexBuffer(4,QSupp1);
   SetIndexBuffer(5,QSupp2);
   SetIndexBuffer(6,QSupp3);
   
   SetIndexStyle(0,DRAW_LINE,0,1);
   SetIndexStyle(1,DRAW_LINE,0,1);
   SetIndexStyle(2,DRAW_LINE,0,1);
   SetIndexStyle(3,DRAW_LINE,0,1);
   SetIndexStyle(4,DRAW_LINE,0,1); 
   SetIndexStyle(5,DRAW_LINE,0,1); 
   SetIndexStyle(6,DRAW_LINE,0,1); 
   

   SetIndexLabel(0,"QR3"); 
   SetIndexLabel(1,"QR2"); 
   SetIndexLabel(2,"QR1");
   SetIndexLabel(3,"QP");
   SetIndexLabel(4,"QS1");
   SetIndexLabel(5,"QS2");
   SetIndexLabel(6,"QS3");
   
   
   IndicatorDigits(Digits);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   ObjectDelete("QPivot");
   ObjectDelete("QSupp1");
   ObjectDelete("QRes1");
   ObjectDelete("QSupp2");
   ObjectDelete("QRes2");
   ObjectDelete("QSupp3");
   ObjectDelete("QRes3");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
         ObjectSetInteger(0,"QPivot",OBJPROP_TIME,Time[0]+(_Period*900));
         ObjectSetInteger(0,"QSupp1",OBJPROP_TIME,Time[0]+(_Period*500));
         ObjectSetInteger(0,"QRes1",OBJPROP_TIME,Time[0]+(_Period*500));
         ObjectSetInteger(0,"QSupp2",OBJPROP_TIME,Time[0]+(_Period*500));
         ObjectSetInteger(0,"QRes2",OBJPROP_TIME,Time[0]+(_Period*500));
         ObjectSetInteger(0,"QSupp3",OBJPROP_TIME,Time[0]+(_Period*500));
         ObjectSetInteger(0,"QRes3",OBJPROP_TIME,Time[0]+(_Period*500));  
   int    counted_bars=IndicatorCounted();
   
   if(counted_bars<0) return(-1);


ObjectCreate("QPivot",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,"QPivot",OBJPROP_ANCHOR,ANCHOR_LEFT);

      ObjectCreate(0,"QSupp1",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,"QSupp1",OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectCreate(0,"QRes1",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,"QRes1",OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectCreate(0,"QSupp2",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,"QSupp2",OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectCreate(0,"QRes2",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,"QRes2",OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectCreate(0,"QSupp3",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,"QSupp3",OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectCreate(0,"QRes3",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,"QRes3",OBJPROP_ANCHOR,ANCHOR_LEFT);
   //---- last counted bar will be recounted
   if(counted_bars>0) 
   {
      counted_bars--;
      //ObjectCreate("Quarterly 50%",OBJ_TEXT,0,0,0);
      //ObjectSetText("Quarterly 50%","                            Quarterly 50%",10,"Arial",Red);
      //ObjectCreate("Quarterly Low",OBJ_TEXT,0,0,0);
      //ObjectSetText("Quarterly Low","        Quarterly Low",10,"Arial",Red);
      //ObjectCreate("Quarterly High",OBJ_TEXT,0,0,0);
      //ObjectSetText("Quarterly High","        Quarterly High",10,"Arial",Red);
   }

   int limit=Bars-counted_bars;
//****************************
  
  
   
   for(int i=1; i<limit; i++)
   { 

      
      // ****************************************************************
      //     Find previous 3 period's high, low and closing bars/prices.
      // ****************************************************************
      
      //Find Our Month date and determine current quarter period beginning.
      datetime thisMonth = Time[i];
      int nMonth = TimeMonth(thisMonth);
      int qtrMonth = 0;
      //int MonthlyBar =  iBarShift( NULL, PERIOD_W1, thisMonth,false)+1; 
      
      switch (nMonth)
      {
         case 1:
         case 4:
         case 7:
         case 10:
            qtrMonth = 1;
            break;
        
        case 2:
        case 5:
        case 8:
        case 11: 
            qtrMonth = 2;
            break;
            
        case 3:
        case 6:
        case 9:
        case 12: 
            qtrMonth = 3;
            break;
       }     
         
          //int Hbar = iHighest(NULL,PERIOD_MN1, MODE_HIGH, shift, toBar),
          //int Lbar =  iLowest(NULL,PERIOD_MN1, MODE_LOW,  shift, toBar);
     /* datetime WeekDate=Time[i];
      int WeeklyBar        =  iBarShift( NULL, PERIOD_W1, WeekDate,false)+1; 
      double PreviousHigh  =  iHigh(NULL, PERIOD_W1,WeeklyBar);
      double PreviousLow   =  iLow(NULL, PERIOD_W1,WeeklyBar);
      double PreviousClose =  iClose(NULL, PERIOD_W1,WeeklyBar);*/
      
      int MonthlyBar     = iBarShift( NULL, PERIOD_MN1, thisMonth,false) + qtrMonth; 
            
      double lastQtrHigh = iHigh(NULL, PERIOD_MN1, iHighest(NULL, PERIOD_MN1, MODE_HIGH, 3, MonthlyBar));
      double lastQtrLow = iLow(NULL, PERIOD_MN1, iLowest(NULL, PERIOD_MN1, MODE_LOW, 3, MonthlyBar));
      double lastQtrClose = iClose(NULL, PERIOD_MN1, MonthlyBar);

      
      //Comment("Period High ",lastQtrHigh," Period Low ",lastQtrLow," Period Close ",lastQtrClose);

      
      // ************************************************************************
      //    Calculate Pivot lines and map into indicator buffers.
      // ************************************************************************
      
      
      double QP =  (lastQtrHigh+lastQtrLow+lastQtrClose)/3;
      double QR1 = (2*QP)-lastQtrLow;
      double QS1 = (2*QP)-lastQtrHigh;
      double QR2 = QP + (lastQtrHigh-lastQtrLow);   
      double QS2 = QP - (lastQtrHigh-lastQtrLow); 
      double QR3 = (2*QP) + (lastQtrHigh - (2*lastQtrLow)); 
      double QS3 = (2*QP)- ((2*lastQtrHigh) - lastQtrLow); 
      double QROVR = lastQtrClose; 

         /*dpR1=(2*dpP)-dpLastLow;
         dpS1=(2*dpP)-dpLastHigh;
         dpR2=dpP+(dpLastHigh - dpLastLow);
         dpS2=dpP-(dpLastHigh - dpLastLow);
         dpR3=(2*dpP)+(dpLastHigh-(2*dpLastLow));
         dpS3=(2*dpP)-((2* dpLastHigh)-dpLastLow);*/      
        
         //----
         ObjectSetText("QPivot"," Q RollOver:"+DoubleToStr(QROVR,Digits),fontsize,"Arial",indicator_color4);
         ObjectSetDouble(0,"QPivot",OBJPROP_PRICE1,QROVR);
      
         ObjectSetText("QSupp1"," QS1:"+DoubleToString(QS1,_Digits),fontsize,"Arial",indicator_color5);
         ObjectSetDouble(0,"QSupp1",OBJPROP_PRICE1,QS1);
         
         ObjectSetText("QRes1"," QR1:"+DoubleToString(QR1,_Digits),fontsize,"Arial",indicator_color3);
         ObjectSetDouble(0,"QRes1",OBJPROP_PRICE1,QR1);
         
         ObjectSetText("QSupp2"," QS2:"+DoubleToString(QS2,_Digits),fontsize,"Arial",indicator_color6);
         ObjectSetDouble(0,"QSupp2",OBJPROP_PRICE1,QS2);
         
         ObjectSetText("QRes2"," QR2:"+DoubleToString(QR2,_Digits),fontsize,"Arial",indicator_color2);
         ObjectSetDouble(0,"QRes2",OBJPROP_PRICE1,QR2);
         
         ObjectSetText("QSupp3"," QS3:"+DoubleToString(QS3,_Digits),fontsize,"Arial",indicator_color7);
         ObjectSetDouble(0,"QSupp3",OBJPROP_PRICE1,QS3);
         
         ObjectSetText("QRes3"," QR3:"+DoubleToString(QR3,_Digits),fontsize,"Arial",indicator_color1);
         ObjectSetDouble(0,"QRes3",OBJPROP_PRICE1,QR3);
     
      QPivot[i]= NormalizeDouble( QROVR, Digits); 
      QRes1[i]= QR1;    
      QSupp1[i]= QS1;   
      QRes2[i] = QR2;    
      QSupp2[i]= QS2;         
      QRes3[i] = QR3;    
      QSupp3[i] = QS3;   

      
   }   
      // ***************************************************************************************
      //                            End of Main Loop
      // ***************************************************************************************


   // *****************************************
   //    Return from Start() (Main Routine)
   return(0);
  }
//+-------------------------------------------------------------------------------------------------------+
//  END Custom indicator iteration function
//+-------------------------------------------------------------------------------------------------------+


// *****************************************************************************************
// *****************************************************************************************
// -----------------------------------------------------------------------------------------
//    The following routine will use "StartingBar"'s time and use it to find the 
//    general area that SHOULD contain the bar that matches "TimeToLookFor"
// -----------------------------------------------------------------------------------------


