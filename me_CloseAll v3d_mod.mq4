//+------------------------------------------------------------------+
//|                                              me_CloseAll v3d.mq4 |
//|                                       Copyright © 2023, frogvu Code. |
//|                                          www.facebook.com/frogvu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2023, frog Code. (www.facebook.com/frogvu)"
#property link      "www.facebook.com/frogvu"
#property strict
#property version "1.01"
#property description "Updated in 2023 by frogvu, Auto SL button (A) to set b/e + points and then ignore the trades after.."

extern int PointsTriggerBE = 112; //Trigger BE Points
extern int PointsTradeBE = 10; //Point to set SL +1 at
extern int PointsTempSL = 2000; // temp SL
extern double SLplus1Mult = 1.0;
int extern SubWindow = 0;
extern int Corner = 2;
extern int Move_X = 0;
extern int Move_Y = 0;
extern string B00001 = "============================";
extern int Button_Width = 70;
extern string Font_Type = "Arial Bold";
extern color Font_Color = clrWhite;
extern int Font_Size = 8;

double Pekali;
int SLplus1AutoState = 0;
string actionS;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   CreateButtons();
   ToolTips_Text("CloseALL_btn");
   ToolTips_Text("Delete___btn");
   ToolTips_Text("ChangeBE_btn");
   ToolTips_Text("SLplusOnebtn");
   ToolTips_Text("SLplusOnebtnAuto");
   ToolTips_Text("DeleteSL_btn");
   ToolTips_Text("ChangeSL_btn");
   ToolTips_Text("ChangeTP_btn");

   ObjectCreate("SL_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet("SL_Edit", OBJPROP_CORNER, Corner);
   ObjectSet("SL_Edit", OBJPROP_XSIZE, Button_Width + 020);
   ObjectSet("SL_Edit", OBJPROP_YSIZE, Font_Size*2.8);
   ObjectSet("SL_Edit", OBJPROP_XDISTANCE, 492 + Move_X);
   ObjectSet("SL_Edit", OBJPROP_YDISTANCE, 025 + Move_Y);
   ObjectSet("SL_Edit", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSet("SL_Edit", OBJPROP_COLOR, clrDeepPink);
   ObjectSetText("SL_Edit", DoubleToStr(Bid, Digits), 13, Font_Type, Font_Color);

   ObjectCreate("TP_Edit", OBJ_EDIT, SubWindow, 0, 0);
   ObjectSet("TP_Edit", OBJPROP_CORNER, Corner);
   ObjectSet("TP_Edit", OBJPROP_XSIZE, Button_Width + 020);
   ObjectSet("TP_Edit", OBJPROP_YSIZE, Font_Size*2.8);
   ObjectSet("TP_Edit", OBJPROP_XDISTANCE, 682 + Move_X);
   ObjectSet("TP_Edit", OBJPROP_YDISTANCE, 025 + Move_Y);
   ObjectSet("TP_Edit", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSet("TP_Edit", OBJPROP_COLOR, clrDarkGreen);
   ObjectSetText("TP_Edit", DoubleToStr(Bid, Digits), 13, Font_Type, Font_Color);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(SLplus1AutoState == 1)
      SLplus1__ButtonAuto(actionS);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteButtons();
   ObjectDelete("SL_Edit");
   ObjectDelete("TP_Edit");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButtons()
  {
   int Button_Height = (int)(Font_Size*2.8);
   if(!ButtonCreate(0, "CloseALL_btn", 0, 002 + 000 + Move_X, 020 + 005 + Move_Y, Button_Width + 000, Button_Height, Corner, "Close All", Font_Type, Font_Size, Font_Color, clrTeal, clrYellow))
      return;
   if(!ButtonCreate(0, "Delete___btn", 0, 002 + 075 + Move_X, 020 + 005 + Move_Y, Button_Width + 000, Button_Height, Corner, "Delete All",Font_Type, Font_Size, Font_Color, clrTeal, clrYellow))
      return;
   if(!ButtonCreate(0, "ChangeBE_btn", 0, 002 + 165 + Move_X, 020 + 005 + Move_Y, Button_Width + 000, Button_Height, Corner, "SL = BE",Font_Type, Font_Size, Font_Color, clrCrimson, clrYellow))
      return;
   if(!ButtonCreate(0, "SLplusOnebtn", 0, 002 + 240 + Move_X, 020 + 005 + Move_Y, Button_Width-20 + 000, Button_Height, Corner, "SL + 1",Font_Type, Font_Size, Font_Color, clrCrimson, clrYellow))
      return;
   if(!ButtonCreate(0, "DeleteSL_btn", 0, 002 + 315 + Move_X, 020 + 005 + Move_Y, Button_Width + 000, Button_Height, Corner, "Delete SL",Font_Type, Font_Size, Font_Color, clrBlue, clrYellow))
      return;
   if(!ButtonCreate(0, "ChangeSL_btn", 0, 002 + 400 + Move_X, 020 + 005 + Move_Y, Button_Width + 020, Button_Height, Corner, "Change SL >>",Font_Type, Font_Size, Font_Color, clrDeepPink, clrYellow))
      return;
   if(!ButtonCreate(0, "ChangeTP_btn", 0, 002 + 590 + Move_X, 020 + 005 + Move_Y, Button_Width + 020, Button_Height, Corner, "Change TP >>",Font_Type, Font_Size, Font_Color, clrDarkGreen, clrYellow))
      return;
//Mod to add Auto button on side...
   if(!ButtonCreate(0, "SLplusOnebtnAuto", 0, 002 + 291 + Move_X, 020 + 005 + Move_Y, Button_Width-50 + 000, Button_Height, Corner, "A",Font_Type, Font_Size, Font_Color, clrCrimson, clrYellow))
      return;
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &action)
  {
   ResetLastError();
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(ObjectType(action) == OBJ_BUTTON)
        {
         ButtonPressed(0, action);
         actionS = action;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ButtonPressed(const long chartID, const string action)
  {
   ObjectSetInteger(chartID, action, OBJPROP_BORDER_COLOR, clrBlack);  // button pressed
   if(action == "CloseALL_btn")
      CloseAll_Button(action);
   if(action == "Delete___btn")
      Delete___Button(action);
   if(action == "ChangeBE_btn")
      ChangeBE_Button(action);
   if(action == "SLplusOnebtn")
      SLplus1__Button(action);
   if(action == "SLplusOnebtnAuto")
      CheckState(action);
   if(action == "DeleteSL_btn")
      DeleteSL_Button(action);
   if(action == "ChangeSL_btn")
      ChangeSL_Button(action);
   if(action == "ChangeTP_btn")
      ChangeTP_Button(action);
   Sleep(1000);
   ObjectSetInteger(chartID, action, OBJPROP_BORDER_COLOR, clrYellow);  // button unpressed
   ObjectSetInteger(chartID, action, OBJPROP_STATE, false);  // button unpressed
   Print(action);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteButtons()
  {
   ButtonDelete(0, "CloseALL_btn");
   ButtonDelete(0, "Delete___btn");
   ButtonDelete(0, "ChangeBE_btn");
   ButtonDelete(0, "SLplusOnebtn");
   ButtonDelete(0, "SLplusOnebtnAuto");
   ButtonDelete(0, "DeleteSL_btn");
   ButtonDelete(0, "ChangeSL_btn");
   ButtonDelete(0, "ChangeTP_btn");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ToolTips_Text(const string action)
  {
   if(action == "CloseALL_btn")
     {
      ObjectSetString(0, action, OBJPROP_TOOLTIP, "Close Open Order(s) for **Current Chart** ONLY");
     }
   if(action == "Delete___btn")
     {
      ObjectSetString(0, action, OBJPROP_TOOLTIP, "Delete Pending Order(s) for **Current Chart** ONLY");
     }
   if(action == "ChangeBE_btn")
     {
      ObjectSetString(0, action, OBJPROP_TOOLTIP, "Set SL to BE for ALL Open Order(s)together on **Current Chart** ONLY");
     }
   if(action == "SLplusOnebtn")
     {
      ObjectSetString(0, action, OBJPROP_TOOLTIP, "Add 1 pip to current SL price for ALL Open Order(s) on **Current Chart** ONLY");
     }
   if(action == "SLplusOnebtnAuto")
     {
      ObjectSetString(0, action, OBJPROP_TOOLTIP, "Individually sets trades to BE + PointsTradeBE for Open Order(s) on **Current Chart** ONLY, Automatically until turned off");
     }
   if(action == "DeleteSL_btn")
     {
      ObjectSetString(0, action, OBJPROP_TOOLTIP, "Remove current SL value for ALL Open Order(s) on **Current Chart** ONLY");
     }
   if(action == "ChangeSL_btn")
     {
      ObjectSetString(0, action, OBJPROP_TOOLTIP, "Change SL value for ALL Open Order(s) on **Current Chart** ONLY");
     }
   if(action == "ChangeTP_btn")
     {
      ObjectSetString(0, action, OBJPROP_TOOLTIP, "Change TP value for ALL Open Order(s) on **Current Chart** ONLY");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAll_Button(const string action)
  {
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol())
           {
            ticket = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, clrNONE);
            if(ticket == -1)
               Print("Error : ", GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol())
           {
            ticket = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3, clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Delete___Button(const string action)
  {
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == OP_BUYLIMIT && OrderSymbol() == Symbol())
           {
            ticket = OrderDelete(OrderTicket(), clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
         if(OrderType() == OP_SELLLIMIT && OrderSymbol() == Symbol())
           {
            ticket = OrderDelete(OrderTicket(), clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
         if(OrderType() == OP_BUYSTOP && OrderSymbol() == Symbol())
           {
            ticket = OrderDelete(OrderTicket(), clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
         if(OrderType() == OP_SELLSTOP && OrderSymbol() == Symbol())
           {
            ticket = OrderDelete(OrderTicket(), clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChangeBE_Button(const string action)
  {
   double Gigits = MarketInfo(Symbol(), MODE_DIGITS);
   if(Gigits == 2)
      Pekali = 100;
   if(Gigits == 3)
      Pekali = 100;
   if(Gigits == 4)
      Pekali = 10000;
   if(Gigits == 5)
      Pekali = 10000;

   double Sel_BE_Price = 0;
   double Buy_BE_Price = 0;
   double Total_Sell_Size = 0;
   double Total_Buy_Size = 0;

   for(int k = 0; k < OrdersTotal(); k++)
     {
      OrderSelect(k, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY)
           {
            Buy_BE_Price += OrderOpenPrice()*OrderLots();
            Total_Buy_Size += OrderLots();
           }
         if(OrderType() == OP_SELL)
           {
            Sel_BE_Price += OrderOpenPrice()*OrderLots();
            Total_Sell_Size += OrderLots();
           }
        }
     }

   if(Buy_BE_Price > 0)
     {
      Buy_BE_Price /= Total_Buy_Size;
     }
   if(Sel_BE_Price > 0)
     {
      Sel_BE_Price /= Total_Sell_Size;
     }

   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int m = OrdersTotal() - 1; m >= 0; m--)
     {
      if(OrderSelect(m, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol())
           {
            ticket = OrderModify(OrderTicket(), 0, Buy_BE_Price + 0/Pekali, OrderTakeProfit(), 0, clrNONE);
            if(ticket == -1)
               Print("Error : ", GetLastError());
            if(ticket >   0)
               Print("SL Position for ", OrderTicket()," modified.");
           }
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol())
           {
            ticket = OrderModify(OrderTicket(), 0, Sel_BE_Price - 0/Pekali, OrderTakeProfit(), 0, clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SLplus1__Button(const string action)
  {
   double Gigits = MarketInfo(Symbol(), MODE_DIGITS);
   if(Gigits == 2)
      Pekali = 100;
   if(Gigits == 3)
      Pekali = 100;
   if(Gigits == 4)
      Pekali = 10000;
   if(Gigits == 5)
      Pekali = 10000;

   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int m = OrdersTotal() - 1; m >= 0; m--)
     {
      if(OrderSelect(m, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderStopLoss() != 0)
           {
            ticket = OrderModify(OrderTicket(), 0, OrderStopLoss() + ((1/Pekali)* SLplus1Mult), OrderTakeProfit(), 0, clrNONE);
            if(ticket == -1)
               Print("Error : ", GetLastError());
            if(ticket >   0)
               Print("SL Position for ", OrderTicket()," modified.");
           }
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderStopLoss() != 0)
           {
            ticket = OrderModify(OrderTicket(), 0, OrderStopLoss() - ((1/Pekali)* SLplus1Mult), OrderTakeProfit(), 0, clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SLplus1__ButtonAuto(string action)
  {
   if(OrdersTotal() > 0)
     {

      int ticket,ticket2;
      for(int m = OrdersTotal() - 1; m >= 0; m--)
        {
         if(OrderSelect(m, SELECT_BY_POS, MODE_TRADES) == true)
           {
            if(OrderType() == OP_BUY && OrderSymbol() == Symbol()) 
              {
               if(OrderStopLoss()==0 && Bid > OrderOpenPrice()+PointsTriggerBE*Point)
                 {
                  ticket =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()- PointsTempSL* Point,Digits),OrderTakeProfit(),0,clrGreen);
                  if(ticket == -1)
                     Print("Error : ", GetLastError());
                  if(ticket >   0)
                     Print("Temp SL Position for ", OrderTicket()," modified.");
                 }

               if(OrderStopLoss() <= OrderOpenPrice() && NormalizeDouble(OrderOpenPrice() + PointsTriggerBE * Point,Digits) < Bid)
                 {
                  ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() + PointsTradeBE* Point,Digits), OrderTakeProfit(), 0, clrNONE);
                  if(ticket2 == -1)
                     Print("Error : ", GetLastError());
                  if(ticket2 >   0)
                     Print("SL Position for ", OrderTicket()," modified.");
                 }

              }


            if(OrderType() == OP_SELL && OrderSymbol() == Symbol()) 
              {
               if(OrderStopLoss()==0 && Bid < OrderOpenPrice()-PointsTriggerBE*Point)
                 {
                  ticket =OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+PointsTempSL*Point,Digits),OrderTakeProfit(),0,clrRed);
                  if(ticket == -1)
                     Print("Error : ", GetLastError());
                  if(ticket >   0)
                     Print("Temp SL Position for ", OrderTicket()," modified.");
                 }

               if(OrderStopLoss() >= OrderOpenPrice() &&NormalizeDouble(OrderOpenPrice() - (PointsTriggerBE * Point),Digits) > Ask)
                 {
                  ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() - PointsTradeBE* Point,Digits), OrderTakeProfit(), 0, clrNONE);
                  if(ticket2 == -1)
                     Print("Error : ",  GetLastError());
                  if(ticket2 >   0)
                     Print("Position ", OrderTicket()," closed");
                 }

              }
           }
        }
     }
//return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DeleteSL_Button(const string action)
  {
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int n = OrdersTotal() - 1; n >= 0; n--)
     {
      if(OrderSelect(n, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderStopLoss() != 0)
           {
            ticket = OrderModify(OrderTicket(), 0, 0, OrderTakeProfit(), 0, clrNONE);
            if(ticket == -1)
               Print("Error : ", GetLastError());
            if(ticket >   0)
               Print("SL Position for ", OrderTicket()," modified.");
           }
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderStopLoss() != 0)
           {
            ticket = OrderModify(OrderTicket(), 0, 0, OrderTakeProfit(), 0, clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChangeSL_Button(const string action)
  {
   double SL_Extract = StrToDouble(ObjectGetString(0, "SL_Edit", OBJPROP_TEXT, 0));
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int n = OrdersTotal() - 1; n >= 0; n--)
     {
      if(OrderSelect(n, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol())
           {
            ticket = OrderModify(OrderTicket(), 0, SL_Extract, OrderTakeProfit(), 0, clrNONE);
            if(ticket == -1)
               Print("Error : ", GetLastError());
            if(ticket >   0)
               Print("SL Position for ", OrderTicket()," modified.");
           }
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol())
           {
            ticket = OrderModify(OrderTicket(), 0, SL_Extract, OrderTakeProfit(), 0, clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChangeTP_Button(const string action)
  {
   double TP_Extract = StrToDouble(ObjectGetString(0, "TP_Edit", OBJPROP_TEXT, 0));
   int ticket;
   if(OrdersTotal() == 0)
      return(0);
   for(int n = OrdersTotal() - 1; n >= 0; n--)
     {
      if(OrderSelect(n, SELECT_BY_POS, MODE_TRADES) == true)
        {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol())
           {
            ticket = OrderModify(OrderTicket(), 0, OrderStopLoss(), TP_Extract, 0, clrNONE);
            if(ticket == -1)
               Print("Error : ", GetLastError());
            if(ticket >   0)
               Print("SL Position for ", OrderTicket()," modified.");
           }
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol())
           {
            ticket = OrderModify(OrderTicket(), 0, OrderStopLoss(), TP_Extract, 0, clrNONE);
            if(ticket == -1)
               Print("Error : ",  GetLastError());
            if(ticket >   0)
               Print("Position ", OrderTicket()," closed");
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long chart_ID = 0, const string name = "Button", const int sub_window = 0, const int x = 0, const int y = 0, const int width = 500,
                  const int height = 18, int corner = 0, const string text = "button", const string font = "Arial Bold",
                  const int font_size = 10, const color clr = clrBlack, const color back_clr = C'170,170,170', const color border_clr = clrNONE,
                  const bool state = false, const bool back = false, const bool selection = false, const bool hidden = true, const long z_order = 0)
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID, name, OBJ_BUTTON, SubWindow, 0, 0))
     {
      Print(__FUNCTION__, " : failed to create the button! Error code : ", GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonDelete(const long chart_ID=0, const string name="Button")
  {
   ResetLastError();
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__, ": Failed to delete the button! Error code = ", GetLastError());
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckState(const string action)
  {
   int check = (SLplus1AutoState == 1) ? SLplus1AutoState = 0 : SLplus1AutoState = 1;
   if(SLplus1AutoState == 1)
     {
      ObjectSetInteger(0, action, OBJPROP_BGCOLOR, clrGreen);
      ObjectSetInteger(0, action, OBJPROP_BORDER_COLOR, clrYellow);
     }
   if(SLplus1AutoState ==0)
     {
      ObjectSetInteger(0, action, OBJPROP_BGCOLOR, clrCrimson);
     }
  }
//+------------------------------------------------------------------+
