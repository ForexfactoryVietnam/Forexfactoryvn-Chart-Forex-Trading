//+------------------------------------------------------------------+
//|                                     SNR - Khang Cu Va Ho Tro.mq4 |
//|                                   Copyright ?2022, CeoVuMKT-FXVN |
//|                                                                  |
//| 
//| Bạn được phép sao chép và phân phối tệp này khi bạn thấy phù hợp,|
//| và sửa đổi nó cho phù hợp với mục đích của bạn với điều kiện sau |
//|                                                                  |
//| 1. Bạn không được tính phí cho chỉ báo này hoặc bất kỳ cach nao  |
//|    mà bạn tạo ra từ nó. Nó đã được phát hành tự do, vui lòng giữ |
//|    nó miễn phí.                                                      |
//|                                                                  |
//| 2. Nếu bạn thực hiện các thay đổi, vui lòng không phát hành new  |
//|    sử dụng tên "SNR- Hotro Khangcu".  Hoac khong chinh sua       |
//|    
//| sử dụng tên mới hoặc liên hệ với tôi  nhận các thay đổi của bạn  |
//|    contact (1quanho9@gmail.com).            |
//|                                                                  |
//| 3. Nếu bạn tạo ra một EA sát thủ dựa trên chỉ số này, hã cho tôi |
//|    một ân huệ và gửi cho tôi một bản sao :)                                |
//|                                                                  |
//| Cam on Duong Mon Bang follow free code.                          |                                                           |              |                                                                |
//| this button will also toggle between testing & normal mode. I've |
//| also renamed "Weak" zones to "Possible" and "Proven" zones are   |
//| now renamed to "Weak".
//+------------------------------------------------------------------+



#property copyright "Copyright ?2022 ForexFactoryVietNam"
#property link      "http://www.forexfactoryvn.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrRed
#property indicator_color2 clrRed
#property indicator_color3 clrDodgerBlue
#property indicator_color4 clrDodgerBlue

extern int    BackLimit   = 10000;
extern int    TimeFrame   = 0;
extern string TimeString  = "0=Current, 15=M15, 30=M30, 60=H1, 240=H4, 1440=Day, 10080=Week, 43200=Month";



extern string  SHOW_ZONES            = "==========SHOW ZONES==========";
extern bool   zone_show_untested     = true;
extern bool   zone_show_verified     = true;
extern bool   zone_show_truncoat     = true;
extern bool   zone_show_weak         = false;
extern bool   zone_show_possible     = false;
extern bool   zone_showbroken        = false;

extern string  ZONE_ALERTS           = "==========ZONE ALERTS==========";
extern bool   zone_show_alerts       = true;
extern bool   zone_alert_popups      = true;
extern bool   zone_alert_sounds      = true;
extern bool   send_email             = false;
extern bool   use_push               = false;
extern int    zone_alert_waitseconds = 300; 

extern string  ZONE_ALERTS_FILTER    = "==========FILTER ALERTS==========";
extern bool   filter_zone_alert      = true;
extern bool   filter_MA              = true;
extern  int   TF_MA                  = 60;
extern  int   MA_FAST_PERIOD         = 13;
extern  int   MA_FAST_METHOD         = 1;
extern  int   MA_SLOW_PERIOD         = 48;
extern  int   MA_SLOW_METHOD         = 1;


extern string  STYLE_ZONES            = "==========STYLE ZONES==========";
extern bool   zone_merge             = true;
extern bool   zone_extend            = false;
extern bool   zone_solid             = false;
extern int    zone_linewidth         = 1;
extern int    zone_style             = 0;
extern int    ShiftEndRight          = 3;//extend the end of zones 3 bars beyond last bar
extern int    zone_limit             = 1000;
extern bool   zone_show_info         = true;
extern bool   zone_show_size         = true;
extern int    zone_label_shift       = 3;
extern color  color_label            = clrWhite; //Label color
extern string font_label             = "Courier New"; //Label Font
extern int    size_label             = 9; //Label size

extern string  ZONES_COLOR             = "==========COLOR ZONES==========";
extern color   color_support_possible  = DarkSlateGray;
extern color   color_support_untested  = SeaGreen;
extern color   color_support_verified  = Green;
extern color   color_support_weak      = LimeGreen;
extern color   color_support_turncoat  = OliveDrab;
extern color   color_resist_possible   = Indigo;
extern color   color_resist_untested   = Orchid;
extern color   color_resist_verified   = Crimson;
extern color   color_resist_weak       = Red;
extern color   color_resist_turncoat   = DarkOrange;
extern color   color_broken_weak       = DarkGray;
extern color   color_broken_verified   = Gray;
extern color   color_broken_other      = DimGray;

extern string  ZONE_FRACTALS         = "==========ZONE FRACTALS==========";
extern double zone_fuzzfactor        = 0.75;
extern bool   fractals_show          = false;
extern double fractal_fast_factor    = 3.0;
extern double fractal_slow_factor    = 6.0;

extern string  ZONES_GLOBAL_VAR      = "==========ZONES GLOBAL VARIABLES==========";
extern bool   SetGlobals             = False;

extern string  ZONES_TESTING_MODE    = "==========ZONES TESTING==========";
extern bool   Testing                = false; //TRUE == scrolling back the chart shows PAST zone "look"
extern bool   ShowTestingBtn         = false; //Show button to switch Testing mode On/Off
extern int    TestingBtnX            = 10; //Position of this button
extern int    TestingBtnY            = 120;

int ID = MathRand() * TimeFrame;

string BtnSRTesting = "BtnSRTesting";

double FastDnPts[], FastUpPts[];
double SlowDnPts[], SlowUpPts[];

double zone_hi[], zone_lo[];
int    zone_start[], zone_hits[], zone_type[], zone_strength[], zone_end[], zone_count = 0;
bool   zone_turn[];

#define ZONE_SUPPORT 1
#define ZONE_RESIST  2
#define ZONE_BROKEN  3

#define ZONE_POSSIBLE  0
#define ZONE_TURNCOAT  1
#define ZONE_UNTESTED  2
#define ZONE_VERIFIED  3
#define ZONE_WEAK      4

#define UP_POINT 1
#define DN_POINT -1

int time_offset = 0;

int LastBar = 0; //Last visible bar on the chart - in Testing mode
bool Initialized = false; //Has the INIT function finished?
double PipSize = 0;

int init()
{  Initialized = false;
   if (ShowTestingBtn){
     if (Testing)
       color Color = C'236,233,216';
     else
       Color = clrSlateGray;
     ButtonCreate(0, BtnSRTesting, 0, TestingBtnX, TestingBtnY, 60, 30, CORNER_LEFT_UPPER, "Testing", "Arial", 8, clrBlack, Color, clrGray, false);
   }   
   GetPipInfo();
   
   IndicatorBuffers(4);

   SetIndexBuffer(0, SlowDnPts);
   SetIndexBuffer(1, SlowUpPts);
   SetIndexBuffer(2, FastDnPts);
   SetIndexBuffer(3, FastUpPts);

   if (fractals_show == true)
   {
      SetIndexStyle(0, DRAW_ARROW, 0, 3);
      SetIndexStyle(1, DRAW_ARROW, 0, 3);
      SetIndexStyle(2, DRAW_ARROW, 0, 1);
      SetIndexStyle(3, DRAW_ARROW, 0, 1);
      SetIndexArrow(0, 218);
      SetIndexArrow(1, 217);
      SetIndexArrow(2, 218);
      SetIndexArrow(3, 217);
   }
   else
   {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
   }

   if (TimeFrame != 1 && TimeFrame != 5 && TimeFrame != 15 &&
       TimeFrame != 60 && TimeFrame != 240 && TimeFrame != 1440 &&
       TimeFrame != 10080 && TimeFrame != 43200)
      TimeFrame = 0;

   if (TimeFrame < Period())
      TimeFrame = Period();

   zone_limit = MathMax(zone_limit, 100);
   ArrayResize(zone_hi, zone_limit);
   ArrayResize(zone_lo, zone_limit);
   ArrayResize(zone_start, zone_limit);
   ArrayResize(zone_hits, zone_limit);
   ArrayResize(zone_type, zone_limit);
   ArrayResize(zone_strength, zone_limit);
   ArrayResize(zone_end, zone_limit);
   ArrayResize(zone_turn, zone_limit);
   
   Initialized = true;      
   return(0);
}

int deinit()
{
   DeleteZones();
   DeleteGlobalVars();
   
   ObjectDelete(0, BtnSRTesting);
   return(0);
}

int start()
{
   if (NewBar() == true)
   {  
      int old_zone_count = zone_count;

      FastFractals();
      SlowFractals();
      DeleteZones();
      FindZones();
      DrawZones();
      if (zone_count < old_zone_count)
         DeleteOldGlobalVars(old_zone_count);
   

     if (zone_show_info == true)
     {  
        for (int i=0; i<zone_count; i++)
        {
           string lbl;
           if (zone_strength[i] == ZONE_WEAK)
              lbl = "Weak";
           else if (zone_strength[i] == ZONE_VERIFIED)
              lbl = "Verified";
           else if (zone_strength[i] == ZONE_UNTESTED)
              lbl = "Untested";
           else if (zone_strength[i] == ZONE_TURNCOAT)
              lbl = "Turncoat";
           else
              lbl = "Possible";
  
           if (zone_type[i] == ZONE_SUPPORT)
              lbl = lbl + " Support";
           else
              lbl = lbl + " Resistance";
           
           if (zone_show_size == true)
           {
               int tam = 0;
               tam =  (zone_hi[i] - zone_lo[i]) * (MathPow(10,Digits()));
               lbl = lbl + "(" + tam + "p)";
           }              
  
           if (zone_hits[i] > 0 && zone_strength[i] > ZONE_UNTESTED)
           {
              if (zone_hits[i] == 1)
                 lbl = lbl + ", Test Count=" + zone_hits[i];                 
              else
                 lbl = lbl + ", Test Count=" + zone_hits[i];                 
           }
           
           
  
           int adjust_hpos;
           int wbpc = WindowBarsPerChart();
           int k;
           
           k = Period() * 60 + (20 + StringLen(lbl));
           
           if (wbpc < 80)  
              adjust_hpos = iTime(NULL, TimeFrame, LastBar + 0) + k * 4;
           else if (wbpc < 125)  
              adjust_hpos = iTime(NULL, TimeFrame, LastBar + 0) + k * 8;
           else if (wbpc < 250)
              adjust_hpos = iTime(NULL, TimeFrame, LastBar + 0) + k * 15;
           else if (wbpc < 480)
              adjust_hpos = iTime(NULL, TimeFrame, LastBar + 0) + k * 29;
           else if (wbpc < 950)
              adjust_hpos = iTime(NULL, TimeFrame, LastBar + 0) + k * 58;
           else
              adjust_hpos = iTime(NULL, TimeFrame, LastBar + 0) + k * 115;
           
           
           if (LastBar > 0)
             int shift = - 77 * Period() * 60; //maybe we should use   -zone_label_shift * k
           else
             shift = k * zone_label_shift;
             
           double vpos = zone_hi[i] - (zone_hi[i] - zone_lo[i]) / 2;
           
           if (zone_strength[i] == ZONE_UNTESTED && zone_show_untested == False)
           {
              continue;
           }
           
           if (zone_strength[i] == ZONE_VERIFIED && zone_show_verified == False)
           {
              continue;
           }
           
           if (zone_strength[i] == ZONE_WEAK && zone_show_weak == False)
           {
              continue;
           }
            
           if (zone_strength[i] == ZONE_TURNCOAT && zone_show_truncoat == False)
           {
              continue;
           }
           
           if (zone_strength[i] == ZONE_POSSIBLE && zone_show_possible == False)
           {
              continue;
           }
             
           string s = "SSSR#"+i+"LBL";
           ObjectCreate(s, OBJ_TEXT, 0, 0, 0);
           ObjectSet(s, OBJPROP_TIME1, adjust_hpos + shift);
           ObjectSet(s, OBJPROP_PRICE1, vpos);
           ObjectSetText(s, StringRightPad(lbl, 36, " "), size_label, font_label, color_label);
        }
     }
   }
   CheckAlerts();

   return(0);
}


void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{   
  if (id == CHARTEVENT_OBJECT_CLICK){
    if (sparam == BtnSRTesting){
      Testing = !Testing;
      if (Testing)
        ObjectSetInteger(0, BtnSRTesting, OBJPROP_BGCOLOR, C'236,233,216');   
      else
        ObjectSetInteger(0, BtnSRTesting, OBJPROP_BGCOLOR, clrSlateGray);
    }
  }
  if (Testing && Initialized && id == CHARTEVENT_CHART_CHANGE){
    int PrevLastBar = LastBar;
    if (LastBar > 0){
      //ExtDownFractalsBuffer[LastBar] = PrevDn;      
      LastBar = 0;
    }
    LastBar = GetNextBar(0);    
   
    if (Testing && PrevLastBar > 0 && LastBar >= 0 && PrevLastBar != LastBar)
      start();
  }
}

void CheckAlerts()
{
   static int lastalert = 0;

   if (zone_show_alerts == false)
      return;

   if (Time[0] - lastalert > zone_alert_waitseconds)
      if (CheckEntryAlerts() == true)
         lastalert = Time[0];
}

bool CheckEntryAlerts()
{
   // check for entries
   bool OK_ALERT = false;
      
   for (int i=0; i<zone_count; i++)
   {   
      OK_ALERT = false;
         
      if (Close[0] >= zone_lo[i] && Close[0] < zone_hi[i])
      {
         if (zone_show_alerts == true)
         {         
         
            if (zone_strength[i] == ZONE_UNTESTED && zone_show_untested == True)
            {
               OK_ALERT = True;
            }
            
            if (zone_strength[i] == ZONE_VERIFIED && zone_show_verified == True)
            {
               OK_ALERT = True;
            }
            
            if (zone_strength[i] == ZONE_WEAK && zone_show_weak == True)
            {
               OK_ALERT = True;
            }
             
            if (zone_strength[i] == ZONE_TURNCOAT && zone_show_truncoat == True)
            {
               OK_ALERT = True;
            }
            
            if (zone_strength[i] == ZONE_POSSIBLE && zone_show_possible == True)
            {
               OK_ALERT = True;
            }
            
            if((filter_zone_alert == True) && (filter_MA == True) && (OK_ALERT == True))
            {
               double FMA = iMA(NULL,TF_MA,MA_FAST_PERIOD,0,MA_FAST_METHOD,PRICE_CLOSE,0);
               double SMA = iMA(NULL,TF_MA,MA_SLOW_PERIOD,0,MA_SLOW_METHOD,PRICE_CLOSE,0);
               
               if((FMA >= SMA) && (zone_type[i] == ZONE_RESIST))
               {
                  OK_ALERT = False;
               }
               
               if ((FMA <= SMA) && (zone_type[i] == ZONE_SUPPORT)) 
               {
                  OK_ALERT = False; 
               } 
                                    
            }
            
            if ((zone_alert_popups == true) && (OK_ALERT == True))
            {
               if (zone_type[i] == ZONE_SUPPORT)
                  Alert(Symbol() + TimeFrameToString(TimeFrame) + ": [Support] Zone Entered");
               else
                  Alert(Symbol() + TimeFrameToString(TimeFrame) + ": [Resistance] Zone Entered");
            }
            

            if ((zone_alert_sounds == true) && (OK_ALERT == True))
            {
               PlaySound("alert.wav");
            }
            
            if ((send_email == true) && (OK_ALERT == True))
            {
               string dir = "";
               string msg = StringConcatenate(Symbol(), "-", TimeFrameToString(TimeFrame), " at ", TimeToStr(Time[0], TIME_DATE|TIME_SECONDS),
                                              " ", dir, " Zone Entered");
               if (zone_type[i] == ZONE_SUPPORT)
               {
                  dir = "Support";
                  SendMail("SS_SupRes_v7.5 alert", msg);
               }
               else
               {
                  dir = "Resistance";
                  SendMail("SS_SupRes_v7.5 alert", msg);
               }
            }
            
            if ((use_push == true) && (OK_ALERT == True))
            {
               string dirp = "";
               string msgp = StringConcatenate(Symbol(), "-", TimeFrameToString(TimeFrame), " at ", TimeToStr(Time[0], TIME_DATE|TIME_SECONDS),
                                              " ", dirp, " Zone Entered");
               if (zone_type[i] == ZONE_SUPPORT)
               {
                  dirp = "[Support]";
                  SendNotification("SS_SupRes_v07.5 alert" + msgp);
               }
               else
               {
                  dirp = "[Resistance]";
                  SendNotification("SS_SupRes_v07.5 alert: " + msgp);
               }
                msgp = StringConcatenate(Symbol(), "-", TimeFrameToString(TimeFrame), " at ", TimeToStr(Time[0], TIME_DATE|TIME_SECONDS),
                                              " ", dirp, " Zone Entered");
               
               SendNotification("SS_SupRes_v07.5 alert: " + msgp);
            }
         }
         
         return(true);   
      }
   }

   return(false);
}

void DeleteGlobalVars()
{
   if (SetGlobals == false)
      return;

   GlobalVariableDel("SSSR_Count_"+Symbol()+TimeFrame);
   GlobalVariableDel("SSSR_Updated_"+Symbol()+TimeFrame);

   int old_count = zone_count;
   zone_count = 0;
   DeleteOldGlobalVars(old_count);
}

void DeleteOldGlobalVars(int old_count)
{
   if (SetGlobals == false)
      return;

   for (int i=zone_count; i<old_count; i++)
   {
      GlobalVariableDel("SSSR_HI_"+Symbol()+TimeFrame+i);
      GlobalVariableDel("SSSR_LO_"+Symbol()+TimeFrame+i);
      GlobalVariableDel("SSSR_HITS_"+Symbol()+TimeFrame+i);
      GlobalVariableDel("SSSR_STRENGTH_"+Symbol()+TimeFrame+i);
      GlobalVariableDel("SSSR_AGE_"+Symbol()+TimeFrame+i);
   }
}

void FindZones()
{
   int i, j, shift, bustcount=0, testcount = 0, brokebar;
   double hival, loval;
   bool turned = false, hasturned = false;

   double temp_hi[1000], temp_lo[1000];
   int    temp_start[1000], temp_hits[1000], temp_strength[1000], temp_count = 0;
   bool   temp_turn[1000], temp_merge[1000];
   double bust_hi[1000], bust_lo[1000];
   int    bust_start[1000], bust_hits[1000], bust_strength[1000], bust_end[1000], bust_count = 0;
   bool   bust_turn[1000], bust_merge[1000];
   int merge1[1000], merge2[1000], merge_count = 0;
   int berge1[1000], berge2[1000], berge_count = 0;

   // iterate through zones from oldest to youngest (ignore recent 5 bars),
   // finding those that have survived through to the present...
   for (shift=MathMin(Bars(NULL, TimeFrame)-1, LastBar + BackLimit); shift> LastBar + 5; shift--)
   {
      double atr = iATR(NULL, TimeFrame, 7, shift);
      double fu = atr/2 * zone_fuzzfactor;
      bool isPossible;
      bool touchOk = false;
      bool isBust = false;
      double close = iClose(NULL, TimeFrame, shift);
      double high  = iHigh(NULL, TimeFrame, shift);
      double low   = iLow(NULL, TimeFrame, shift);
      double hi_i;
      double lo_i;

      if (FastUpPts[shift] > 0.001)
      {
         // a zigzag high point
         isPossible = true;
         if (SlowUpPts[shift] > 0.001)
            isPossible = false;

         hival = high;
         if (zone_extend == true)
            hival += fu;

         loval = MathMax(MathMin(close, high-fu), high-fu*2);
         turned = false;
         hasturned = false;
         isBust = false;

         bustcount = 0;
         testcount = 0;
         brokebar = 0;

         for (i=shift-1; i>=LastBar + 0; i--)
         {
            hi_i = iHigh(NULL, TimeFrame, i);
            lo_i = iLow(NULL, TimeFrame, i);

            if ((turned == false && FastUpPts[i] >= loval && FastUpPts[i] <= hival) ||
                (turned == true && FastDnPts[i] <= hival && FastDnPts[i] >= loval))
            {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk = true;
               for (j=i+1; j<i+11; j++)
               {
                  if ((turned == false && FastUpPts[j] >= loval && FastUpPts[j] <= hival) ||
                      (turned == true && FastDnPts[j] <= hival && FastDnPts[j] >= loval))
                  {
                     touchOk = false;
                     break;
                  }
               }

               if (touchOk == true)
               {
                  // we have a touch.  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount = 0;
                  testcount++;
               }
            }

            if ((turned == false && hi_i > hival) ||
                (turned == true && lo_i < loval))
            {
               // this level has been busted at least once
               bustcount++;
               brokebar = MathMax(brokebar, i);

               if (bustcount > 1 || isPossible == true)
               {
                  // busted twice or more
                  isBust = true;
                  break;
               }

               if (turned == true)
                  turned = false;
               else if (turned == false)
                  turned = true;

               hasturned = true;

               // forget previous hits
               testcount = 0;
            }
         }

         if (isBust == false)
         {
            // level is still valid, add to our list
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_start[temp_count] = shift;
            temp_merge[temp_count] = false;
            
            if (testcount > 3)
               temp_strength[temp_count] = ZONE_WEAK;
            else if (testcount > 0)
               temp_strength[temp_count] = ZONE_VERIFIED;
            else if (hasturned == true)
               temp_strength[temp_count] = ZONE_TURNCOAT;
            else if (isPossible == false)
               temp_strength[temp_count] = ZONE_UNTESTED;
            else
               temp_strength[temp_count] = ZONE_POSSIBLE;

            temp_count++;
         }
         else if (zone_showbroken)
         {
            // level is broken, but we're showing it anyway
            bust_hi[bust_count] = hival;
            bust_lo[bust_count] = loval;
            bust_turn[bust_count] = hasturned;
            bust_hits[bust_count] = testcount;
            bust_start[bust_count] = shift;
            bust_end[bust_count] = brokebar;
            bust_merge[bust_count] = false;

            if (testcount > 3)
               bust_strength[bust_count] = ZONE_WEAK;
            else if (testcount > 0)
               bust_strength[bust_count] = ZONE_VERIFIED;
            else if (hasturned == true)
               bust_strength[bust_count] = ZONE_TURNCOAT;
            else if (isPossible == false)
               bust_strength[bust_count] = ZONE_UNTESTED;
            else
               bust_strength[bust_count] = ZONE_POSSIBLE;

            bust_count++;
         }
      }
      else if (FastDnPts[shift] > 0.001)
      {
         // a zigzag low point
         isPossible = true;
         if (SlowDnPts[shift] > 0.001)
            isPossible = false;

         loval = low;
         if (zone_extend == true)
            loval -= fu;

         hival = MathMin(MathMax(close, low+fu), low+fu*2);
         turned = false;
         hasturned = false;

         bustcount = 0;
         testcount = 0;
         brokebar  = 0;
         isBust = false;

         for (i=shift-1; i>=LastBar + 0; i--)
         {
            hi_i = iHigh(NULL, TimeFrame, i);
            lo_i = iLow(NULL, TimeFrame, i);

            if ((turned == true && FastUpPts[i] >= loval && FastUpPts[i] <= hival) ||
                (turned == false && FastDnPts[i] <= hival && FastDnPts[i] >= loval))
            {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk = true;
               for (j=i+1; j<i+11; j++)
               {
                  if ((turned == true && FastUpPts[j] >= loval && FastUpPts[j] <= hival) ||
                      (turned == false && FastDnPts[j] <= hival && FastDnPts[j] >= loval))
                  {
                     touchOk = false;
                     break;
                  }
               }

               if (touchOk == true)
               {
                  // we have a touch.  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount = 0;
                  testcount++;
               }
            }

            if ((turned == true && hi_i > hival) ||
                (turned == false && lo_i < loval))
            {
               // this level has been busted at least once
               bustcount++;
               brokebar = MathMax(brokebar, i);

               if (bustcount > 1 || isPossible == true)
               {
                  // busted twice or more
                  isBust = true;
                  break;
               }

               if (turned == true)
                  turned = false;
               else if (turned == false)
                  turned = true;

               hasturned = true;

               // forget previous hits
               testcount = 0;
            }
         }

         if (isBust == false)
         {
            // level is still valid, add to our list
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_start[temp_count] = shift;
            temp_merge[temp_count] = false;

            if (testcount > 3)
               temp_strength[temp_count] = ZONE_WEAK;
            else if (testcount > 0)
               temp_strength[temp_count] = ZONE_VERIFIED;
            else if (hasturned == true)
               temp_strength[temp_count] = ZONE_TURNCOAT;
            else if (isPossible == false)
               temp_strength[temp_count] = ZONE_UNTESTED;
            else
               temp_strength[temp_count] = ZONE_POSSIBLE;

            temp_count++;
         }
         else if (zone_showbroken)
         {
            // level is broken, but we're showing it anyway
            bust_hi[bust_count] = hival;
            bust_lo[bust_count] = loval;
            bust_turn[bust_count] = hasturned;
            bust_hits[bust_count] = testcount;
            bust_start[bust_count] = shift;
            bust_end[bust_count] = brokebar;
            bust_merge[bust_count] = false;

            if (testcount > 3)
               bust_strength[bust_count] = ZONE_WEAK;
            else if (testcount > 0)
               bust_strength[bust_count] = ZONE_VERIFIED;
            else if (hasturned == true)
               bust_strength[bust_count] = ZONE_TURNCOAT;
            else if (isPossible == false)
               bust_strength[bust_count] = ZONE_UNTESTED;
            else
               bust_strength[bust_count] = ZONE_POSSIBLE;

            bust_count++;
         }
      }
   }

   // look for overlapping zones...
   if (zone_merge == true)
   {
      merge_count = 1;
      int iterations = 0, target, source;
      while (merge_count > 0 && iterations < 3)
      {
         merge_count = 0;
         iterations++;

         for (i = 0; i < temp_count; i++)
            temp_merge[i] = false;

         for (i = 0; i < temp_count-1; i++)
         {
            if (temp_hits[i] == -1 || temp_merge[j] == true)
               continue;

            for (j = i+1; j < temp_count; j++)
            {
               if (temp_hits[j] == -1 || temp_merge[j] == true)
                  continue;

               if ((temp_hi[i] >= temp_lo[j] && temp_hi[i] <= temp_hi[j]) ||
                   (temp_lo[i] <= temp_hi[j] && temp_lo[i] >= temp_lo[j]) ||
                   (temp_hi[j] >= temp_lo[i] && temp_hi[j] <= temp_hi[i]) ||
                   (temp_lo[j] <= temp_hi[i] && temp_lo[j] >= temp_lo[i]))
               {
                  merge1[merge_count] = i;
                  merge2[merge_count] = j;
                  temp_merge[i] = true;
                  temp_merge[j] = true;
                  merge_count++;
               }
            }
         }

         // ... and merge them ...
         for (i=0; i<merge_count; i++)
         {
            target = merge1[i];
            source = merge2[i];

            temp_hi[target] = MathMax(temp_hi[target], temp_hi[source]);
            temp_lo[target] = MathMin(temp_lo[target], temp_lo[source]);
            temp_hits[target] += temp_hits[source];
            temp_start[target] = MathMax(temp_start[target], temp_start[source]);
            temp_strength[target] = MathMax(temp_strength[target], temp_strength[source]);
            if (temp_hits[target] > 3)
               temp_strength[target] = ZONE_WEAK;

            if (temp_hits[target] == 0 && temp_turn[target] == false)
            {
               temp_hits[target] = 1;
               if (temp_strength[target] < ZONE_VERIFIED)
                  temp_strength[target] = ZONE_VERIFIED;
            }

            if (temp_turn[target] == false || temp_turn[source] == false)
               temp_turn[target] = false;
            if (temp_turn[target] == true)
               temp_hits[target] = 0;

            temp_hits[source] = -1;
         }
      }
   
      if (zone_showbroken)
      {
         // merge busted zones
         berge_count = 1;
         iterations = 0;
         while (berge_count > 0 && iterations < 3)
         {
            berge_count = 0;
            iterations++;
   
            for (i = 0; i < bust_count; i++)
               bust_merge[i] = false;

            for (i = 0; i < bust_count-1; i++)
            {
               if (bust_hits[i] == -1 || bust_merge[j] == true)
                  continue;

               for (j = i+1; j < bust_count; j++)
               {
                  if (bust_hits[j] == -1 || bust_merge[j] == true)
                     continue;

                  if ((bust_hi[i] >= bust_lo[j] && bust_hi[i] <= bust_hi[j]) ||
                      (bust_lo[i] <= bust_hi[j] && bust_lo[i] >= bust_lo[j]) ||
                      (bust_hi[j] >= bust_lo[i] && bust_hi[j] <= bust_hi[i]) ||
                      (bust_lo[j] <= bust_hi[i] && bust_lo[j] >= bust_lo[i]))
                  {
                     berge1[berge_count] = i;
                     berge2[berge_count] = j;
                     bust_merge[i] = true;
                     bust_merge[j] = true;
                     berge_count++;
                  }
               }
            }

            // ... and merge them ...
            for (i=0; i<berge_count; i++)
            {
               target = berge1[i];
               source = berge2[i];

               bust_hi[target] = MathMax(bust_hi[target], bust_hi[source]);
               bust_lo[target] = MathMin(bust_lo[target], bust_lo[source]);
               bust_hits[target] += bust_hits[source];
               bust_start[target] = MathMax(bust_start[target], bust_start[source]);
               bust_end[target] = MathMax(bust_end[target], bust_end[source]);
               bust_strength[target] = MathMax(bust_strength[target], bust_strength[source]);
               if (bust_hits[target] > 3)
                  bust_strength[target] = ZONE_WEAK;

               if (bust_hits[target] == 0 && bust_turn[target] == false)
               {
                  bust_hits[target] = 1;
                  if (bust_strength[target] < ZONE_VERIFIED)
                     bust_strength[target] = ZONE_VERIFIED;
               }

               if (bust_turn[target] == false || bust_turn[source] == false)
                  bust_turn[target] = false;
               if (bust_turn[target] == true)
                  bust_hits[target] = 0;

               bust_hits[source] = -1;
            }
         }
      }
   }

   // copy the remaining list into our official zones arrays
   zone_count = 0;
   for (i=0; i<temp_count; i++)
   {
      if (temp_hits[i] >= 0 && zone_count < zone_limit)
      {
         zone_hi[zone_count]       = temp_hi[i];
         zone_lo[zone_count]       = temp_lo[i];
         zone_hits[zone_count]     = temp_hits[i];
         zone_turn[zone_count]     = temp_turn[i];
         zone_start[zone_count]    = temp_start[i];
         zone_strength[zone_count] = temp_strength[i];
         zone_end[zone_count]      = LastBar + 0;
         
         if (zone_hi[zone_count] < iClose(NULL, TimeFrame, LastBar + 4))
            zone_type[zone_count] = ZONE_SUPPORT;
         else if (zone_lo[zone_count] > iClose(NULL, TimeFrame, LastBar + 4))
            zone_type[zone_count] = ZONE_RESIST;
         else
         {
            for (j=LastBar + 5; j< LastBar + 1000; j++)
            {
               if (iClose(NULL, TimeFrame, j) < zone_lo[zone_count])
               {
                  zone_type[zone_count] = ZONE_RESIST;
                  break;
               }
               else if (iClose(NULL, TimeFrame, j) > zone_hi[zone_count])
               {
                  zone_type[zone_count] = ZONE_SUPPORT;
                  break;
               }
            }

            if (j == LastBar + 1000)
               zone_type[zone_count] = ZONE_SUPPORT;
         }

         zone_count++;
      }
   }

   if (zone_showbroken)
   {
      for (i=bust_count-1; i>=0; i--)
      {
         if (bust_hits[i] >= 0 && zone_count < zone_limit)
         {
            zone_hi[zone_count]       = bust_hi[i];
            zone_lo[zone_count]       = bust_lo[i];
            zone_hits[zone_count]     = bust_hits[i];
            zone_turn[zone_count]     = bust_turn[i];
            zone_start[zone_count]    = bust_start[i];
            zone_strength[zone_count] = bust_strength[i];
            zone_end[zone_count]      = bust_end[i];
            zone_type[zone_count]     = ZONE_BROKEN;
            zone_count++;
         }
      }
   }
}

void DrawZones()
{
   if (SetGlobals == true)
   {
      GlobalVariableSet("SSSR_Count_"+Symbol()+TimeFrame, zone_count);
      GlobalVariableSet("SSSR_Updated_"+Symbol()+TimeFrame, TimeCurrent());
   }

   for (int i=0; i<zone_count; i++)
   {
   
      if (zone_strength[i] == ZONE_UNTESTED && zone_show_untested == False)
      {
         continue;
      }
     
      if (zone_strength[i] == ZONE_VERIFIED && zone_show_verified == False)
      {
         continue;
      }
   
      if (zone_strength[i] == ZONE_POSSIBLE && zone_show_possible == false)
         continue;
         
      if (zone_strength[i] == ZONE_WEAK && zone_show_weak == false)
         continue;

      if (zone_strength[i] == ZONE_TURNCOAT && zone_show_truncoat == false)
         continue;

      string s = "SSSR#"+i+" Strength=";
      if (zone_strength[i] == ZONE_WEAK)
         s = s + "Weak, Test Count=" + zone_hits[i];
      else if (zone_strength[i] == ZONE_VERIFIED)
         s = s + "Verified, Test Count=" + zone_hits[i];
      else if (zone_strength[i] == ZONE_UNTESTED)
         s = s + "Untested";
      else if (zone_strength[i] == ZONE_TURNCOAT)
         s = s + "Turncoat";
      else
         s = s + "Possible";
         

      ObjectCreate(s, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
      ObjectSet(s, OBJPROP_TIME1, iTime(NULL, TimeFrame, zone_start[i]));
      if (LastBar > 0)
        ObjectSet(s, OBJPROP_TIME2, iTime(NULL, TimeFrame, zone_end[i]) - ShiftEndRight * Period() * 60);
      else
        ObjectSet(s, OBJPROP_TIME2, iTime(NULL, TimeFrame, zone_end[i]) + ShiftEndRight * Period() * 60);
      ObjectSet(s, OBJPROP_PRICE1, zone_hi[i]);
      ObjectSet(s, OBJPROP_PRICE2, zone_lo[i]);
      ObjectSet(s, OBJPROP_BACK, zone_solid);
      ObjectSet(s, OBJPROP_WIDTH, zone_linewidth);
      ObjectSet(s, OBJPROP_STYLE, zone_style);

      if (zone_type[i] == ZONE_SUPPORT)
      {
         // support zone
         if (zone_strength[i] == ZONE_TURNCOAT)
            ObjectSet(s, OBJPROP_COLOR, color_support_turncoat);
         else if (zone_strength[i] == ZONE_WEAK)
            ObjectSet(s, OBJPROP_COLOR, color_support_weak);
         else if (zone_strength[i] == ZONE_VERIFIED)
            ObjectSet(s, OBJPROP_COLOR, color_support_verified);
         else if (zone_strength[i] == ZONE_UNTESTED)
            ObjectSet(s, OBJPROP_COLOR, color_support_untested);
         else
            ObjectSet(s, OBJPROP_COLOR, color_support_possible);
      }
      else if (zone_type[i] == ZONE_RESIST)
      {
         // resistance zone
         if (zone_strength[i] == ZONE_TURNCOAT)
            ObjectSet(s, OBJPROP_COLOR, color_resist_turncoat);
         else if (zone_strength[i] == ZONE_WEAK)
            ObjectSet(s, OBJPROP_COLOR, color_resist_weak);
         else if (zone_strength[i] == ZONE_VERIFIED)
            ObjectSet(s, OBJPROP_COLOR, color_resist_verified);
         else if (zone_strength[i] == ZONE_UNTESTED)
            ObjectSet(s, OBJPROP_COLOR, color_resist_untested);
         else
            ObjectSet(s, OBJPROP_COLOR, color_resist_possible);
      }
      else  // broken zones
      {
         if (zone_strength[i] == ZONE_WEAK)
            ObjectSet(s, OBJPROP_COLOR, color_broken_weak);
         else if (zone_strength[i] == ZONE_VERIFIED)
            ObjectSet(s, OBJPROP_COLOR, color_broken_verified);
         else
            ObjectSet(s, OBJPROP_COLOR, color_broken_other);
      }


      if (SetGlobals == true && zone_type[i] != ZONE_BROKEN)
      {
         GlobalVariableSet("SSSR_HI_"+Symbol()+TimeFrame+i, zone_hi[i]);
         GlobalVariableSet("SSSR_LO_"+Symbol()+TimeFrame+i, zone_lo[i]);
         GlobalVariableSet("SSSR_HITS_"+Symbol()+TimeFrame+i, zone_hits[i]);
         GlobalVariableSet("SSSR_STRENGTH_"+Symbol()+TimeFrame+i, zone_strength[i]);
         GlobalVariableSet("SSSR_AGE_"+Symbol()+TimeFrame+i, zone_start[i]);
      }
   }
}

bool Fractal(int M, int P, int shift)
{
   if (TimeFrame > P)
      P = TimeFrame;
   
   P = P / TimeFrame*2 + MathCeil(P / TimeFrame / 2);
   
   if (shift < P)
      return(false);

   if (shift > Bars(Symbol(), TimeFrame)-P)
      return(false); 
   
   for (int i=1; i<=P; i++)
   {
      if (M == UP_POINT)
      {
         if (iHigh(NULL, TimeFrame, shift+i) > iHigh(NULL, TimeFrame, shift))
            return(false);
         if (iHigh(NULL, TimeFrame, shift-i) >= iHigh(NULL, TimeFrame, shift))
            return(false);     
      }
      if (M == DN_POINT)
      {
         if (iLow(NULL, TimeFrame, shift+i) < iLow(NULL, TimeFrame, shift))
            return(false);
         if (iLow(NULL, TimeFrame, shift-i) <= iLow(NULL, TimeFrame, shift))
            return(false);
      }        
   }
   return(true);   
}  

void FastFractals()
{
   int counted = IndicatorCounted();
   int shift, limit;
   int P = TimeFrame * fractal_fast_factor;

   if (counted < 0) return;
   /** /
   if (counted > 0) 
      limit = MathMin(BackLimit, MathMax(P, Bars(NULL, TimeFrame) - counted));
   else
      limit = MathMin(BackLimit, Bars(NULL, TimeFrame)-1);
   /**/
   limit = MathMin(LastBar + BackLimit, Bars(NULL, TimeFrame)-1); 
   //limit = MathMin(Bars-1, limit);

   FastUpPts[0] = 0.0; FastUpPts[1] = 0.0;
   FastDnPts[0] = 0.0; FastDnPts[1] = 0.0;

   for (shift=limit; shift> LastBar + 1; shift--)
   {
      if (Fractal(UP_POINT, P, shift) == true)
         FastUpPts[shift] = iHigh(NULL, TimeFrame, shift);
      else
         FastUpPts[shift] = 0.0;

      if (Fractal(DN_POINT, P, shift) == true)
         FastDnPts[shift] = iLow(NULL, TimeFrame, shift);
      else
         FastDnPts[shift] = 0.0;
   }
}

void SlowFractals()
{
   int counted = IndicatorCounted();
   int shift, limit;
   int P = TimeFrame * fractal_slow_factor;

   if (counted < 0) return;
   /** /
   if (counted > 0) 
      limit = MathMin(BackLimit, MathMax(P, Bars(NULL, TimeFrame) - counted));
   else
      limit = MathMin(BackLimit, Bars(NULL, TimeFrame)-1);
   /**/
   limit = MathMin(LastBar + BackLimit, Bars(NULL, TimeFrame)-1);   
   // limit = MathMin(Bars-1, limit);

   SlowUpPts[0] = 0.0; SlowUpPts[1] = 0.0;
   SlowDnPts[0] = 0.0; SlowDnPts[1] = 0.0;

   for (shift=limit; shift> LastBar + 1; shift--)
   {
      if (Fractal(UP_POINT, P, shift) == true)
         SlowUpPts[shift] = iHigh(NULL, TimeFrame, shift);
      else
         SlowUpPts[shift] = 0.0;

      if (Fractal(DN_POINT, P, shift) == true)
         SlowDnPts[shift] = iLow(NULL, TimeFrame, shift);
      else
         SlowDnPts[shift] = 0.0;
   }
}

bool NewBar()
{  if (Testing)
     int Shift = LastBar;
   else
     Shift = 0;
   static datetime LastTime = 0;
   if (iTime(NULL, TimeFrame, Shift) != LastTime)
   {
      LastTime = iTime(NULL, TimeFrame, Shift) + time_offset;
      return (true);
   }
   else
      return (false);
}

void DeleteZones()
{
   int len = 5;
   int i;

   while (i < ObjectsTotal())
   {
      string objName = ObjectName(i);
      string objDesc = ObjectDescription(i);
      if (StringSubstr(objName, 0, len) != "SSSR#")
      {
         i++;
         continue;
      }

      ObjectDelete(objName);
   }
}

string TimeFrameToString(int tf) //code by TRO
{
   string tfs;

   switch(tf)
   {
      case PERIOD_M1:
         tfs = "M1"  ;
         break;
      case PERIOD_M5:
         tfs = "M5"  ;
         break;
      case PERIOD_M15:
         tfs = "M15" ;
         break;
      case PERIOD_M30:
         tfs = "M30" ;
         break;
      case PERIOD_H1:
         tfs = "H1"  ;
         break;
      case PERIOD_H4:
         tfs = "H4"  ;
         break;
      case PERIOD_D1:
         tfs = "D1"  ;
         break;
      case PERIOD_W1:
         tfs = "W1"  ;
         break;
      case PERIOD_MN1:
         tfs = "MN";
   }

   return(tfs);
}

string StringRepeat(string str, int n = 1)
{
  string outstr = "";
  for(int i = 0; i < n; i++) outstr = outstr + str;
  return(outstr);
}

string StringRightPad(string str, int n=1, string str2=" ")
{
  return(str + StringRepeat(str2,n-StringLen(str)));
}


void GetPipInfo(){   
//---- Automatically adjust one decimal place left for Gold
   if (Symbol()=="XAUUSD" || Symbol()=="GOLD") 
   {     
      PipSize = 0.1;
   }
   else{ //not GOLD   
     switch (Digits) {
     case 6:
     case 5:
       
        PipSize = 0.0001;
        break;
     case 4:
       
        PipSize = 0.0001;
        break;
     case 3:
       
        PipSize = 0.01;
        break;
     case 2:
       
        PipSize = 0.01;
        break;
     case 1:
       
        PipSize = 0.1;
     }
   }
  
}  


bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=false,              // hidden in the object list
                  const long              z_order=15)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if (ObjectFind(chart_ID, name) < 0)
     if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
       {
        Print(__FUNCTION__,
              ": failed to create the button! Error code = ",GetLastError());
        return(false);
       }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
int GetNextBar(int Shift = 0){ //Zwraca nr ostatniego widocznego po prawej BAR'a. Shift -> RIGTH
  int MinBar = ChartFirstVisibleBar();
  int ChartW = ChartWidthInBars();
  if (ChartShiftGet()){
    double ShiftMargin = ChartShiftSizeGet();
    if (ShiftMargin > 0)
      ChartW = (int)MathRound((100.0 - ShiftMargin)*(double)ChartW/100.0);  
  }
  int MaxBar = MinBar - ChartW;
  MaxBar = MaxBar - Shift;
  if (MaxBar < 0)
    MaxBar = 0;
  return(MaxBar);
}

int ChartFirstVisibleBar(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_FIRST_VISIBLE_BAR,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
  
int ChartWidthInBars(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_WIDTH_IN_BARS,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
  
  
  
double ChartShiftSizeGet(const long chart_ID=0)
  {
//--- prepare the variable to get the result
   double result=EMPTY_VALUE;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetDouble(chart_ID,CHART_SHIFT_SIZE,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return(result);
  }
  
  bool ChartShiftGet(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long value;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_SHIFT,0,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- store the value of the chart property in memory
   //result=value;
//--- successful execution
  if (value > 0)
    return(true);
  else
    return(false);
  }
