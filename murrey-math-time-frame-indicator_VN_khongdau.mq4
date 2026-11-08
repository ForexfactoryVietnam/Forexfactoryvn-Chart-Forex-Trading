//+------------------------------------------------------------------+
//|                                                    TimeFrame.mq4 |
//|   Murrey Math - phien ban 2.1 (Viet hoa + toi uu)                |
//|   Goc: XARD777 (TimeFrame.Modified)                              |
//+------------------------------------------------------------------+
#property copyright "TimeFrame.Modified (Viet hoa)"
#property link      "1quanho9@gmail.com"
#property version   "2.10"
#property strict
#property description "Murrey Math: ve cac muc 0/8 den 8/8 (kem -2/8 den +2/8 va cac duong chia nho 1/4) tu dinh/day cua N nen gan nhat."
#property description "Chi la cong cu tham khao vung ho tro/khang cu, khong phai tin hieu vao lenh."
#property indicator_chart_window

//---- tham so (giu nguyen ten de template cu van nap duoc)
extern int    beginer         = 0;      // Nen bat dau lay du lieu (0 = nen hien tai)
extern int    periodtotake    = 64;     // So nen quet tim dinh/day
extern int    SomeVar         = 0;      // So nen cong them vao so nen quet
extern bool   FixOctaveBug    = true;   // true = thuat toan chuan (co else); false = giu dung cach tinh cu
extern bool   ShowMinorLines  = true;   // Hien cac duong xam chia nho (1/4 cua 1/8)
extern bool   ShowComment     = true;   // Hien bang thong tin o goc bieu do
extern int    LabelBarsBack   = 12;     // Nhan dat cach nen cuoi bao nhieu nen ve ben trai
extern int    LabelFontSize   = 10;     // Co chu nhan

//---- 13 muc chinh: do lech tinh theo 1/8 so voi 0/8 la (chi so - 2)
//     (ten object giu nguyen tieng Anh de tuong thich voi template cu)
string  majName[13] = {"MM-2/8ths", "MM-1/8th", "MM 0/8th", "MM 1/8th", "MM 2/8ths", "MM 3/8ths", "MM 4/8ths",
                       "MM 5/8ths", "MM 6/8ths", "MM 7/8ths", "MM 8/8ths", "MM+1/8th", "MM+2/8ths"};
string  majText[13] = {"-2/8: Vuot muc cuc doan ",
                       "-1/8: Vuot muc ",
                       "0/8: Ho tro cuoi cung ",
                       "1/8: Yeu, de chung lai va dao chieu ",
                       "2/8: Diem xoay, dao chieu quan trong ",
                       "3/8: Day vung giao dich ",
                       "4/8: Ho tro/Khang cu chinh ",
                       "5/8: Dinh vung giao dich ",
                       "6/8: Diem xoay, dao chieu quan trong ",
                       "7/8: Yeu, de chung lai va dao chieu ",
                       "8/8: Khang cu cuoi cung ",
                       "+1/8: Vuot muc ",
                       "+2/8: Vuot muc cuc doan "};
color   majColor[13];

//---- 36 duong phu: do lech tinh theo 1/8 so voi 0/8
string  minName[36] = {"mm1006", "mm1004", "mm1002", "mm106", "mm104", "mm102", "mm02", "mm04", "mm06", "mm12s", "mm14", "mm16", "mm22", "mm24", "mm26", "mm32", "mm34", "mm36", "mm42", "mm44", "mm46", "mm52", "mm54", "mm56", "mm62", "mm64", "mm66", "mm72", "mm74", "mm76", "mm82", "mm84", "mm86", "mm92", "mm94", "mm96"};
double  minOff[36]  = {-1.75, -1.5, -1.25, -0.75, -0.5, -0.25, 0.25, 0.5, 0.75, 1.25, 1.5, 1.75, 2.25, 2.5, 2.75, 3.25, 3.5, 3.75, 4.25, 4.5, 4.75, 5.25, 5.5, 5.75, 6.25, 6.5, 6.75, 7.25, 7.5, 7.75, 8.25, 8.5, 8.75, 9.25, 9.5, 9.75};

datetime g_lastBar = 0;
double   g_finalL  = 0;     // 0/8 cua lan ve truoc
double   g_v45     = 0;     // do rong 1/8 cua lan ve truoc

//+------------------------------------------------------------------+
int OnInit()
  {
   majColor[0]  = Red;          majColor[1]  = OrangeRed;   majColor[2]  = DeepSkyBlue;
   majColor[3]  = Yellow;       majColor[4]  = HotPink;     majColor[5]  = Lime;
   majColor[6]  = DeepSkyBlue;  majColor[7]  = Lime;        majColor[8]  = HotPink;
   majColor[9]  = Yellow;       majColor[10] = DeepSkyBlue; majColor[11] = OrangeRed;
   majColor[12] = Red;
   g_lastBar = 0;
   g_finalL = 0;
   g_v45 = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // chi xoa object cua chinh indicator nay (khong dung toi duong ke cua ban)
   for(int i = 0; i < 13; i++)
     {
      ObjectDelete(0, majName[i]);
      ObjectDelete(0, majName[i] + "_txt");
     }
   for(int j = 0; j < 36; j++)
      ObjectDelete(0, minName[j]);
   Comment("");
  }

//+------------------------------------------------------------------+
//| Chon "master square" (fractal) theo do lon cua gia               |
//+------------------------------------------------------------------+
double MasterSquare(const double v2)
  {
   if(v2 <= 0)          return(0);
   if(v2 > 250000)      return(1000000);
   if(v2 > 25000)       return(100000);
   if(v2 > 2500)        return(10000);
   if(v2 > 250)         return(1000);
   if(v2 > 25)          return(100);
   if(v2 > 12.5)        return(12.5);
   if(v2 > 6.25)        return(12.5);
   if(v2 > 3.125)       return(6.25);
   if(v2 > 1.5625)      return(3.125);
   if(v2 > 0.390625)    return(1.5625);
   return(0.1953125);
  }

//+------------------------------------------------------------------+
//| Cap nhat duong ngang; neu chua co thi tao moi                    |
//+------------------------------------------------------------------+
void PutLine(const string name, const double price, const color clr, const int width, const int style)
  {
   if(ObjectSetDouble(0, name, OBJPROP_PRICE1, price))
      return;                                   // da ton tai va da duoc doi
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

void PutText(const string name, const string text, const double price, const color clr)
  {
   datetime t = Time[(int)MathMin(MathMax(LabelBarsBack, 0), Bars - 1)];
   if(ObjectSetInteger(0, name, OBJPROP_TIME1, t))
     {
      ObjectSetDouble(0, name, OBJPROP_PRICE1, price);
      return;
     }
   ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, LabelFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Tinh octave va ve cac duong                                      |
//+------------------------------------------------------------------+
bool Calculate()
  {
   int count = periodtotake + SomeVar;
   if(count < 2 || beginer < 0 || Bars < beginer + count + 1)
      return(false);

   int lb = iLowest(NULL, 0, MODE_LOW, count, beginer);
   int hb = iHighest(NULL, 0, MODE_HIGH, count, beginer);
   if(lb < 0 || hb < 0)
      return(false);
   double v1 = Low[lb];       // day thap nhat
   double v2 = High[hb];      // dinh cao nhat

   double range = v2 - v1;
   double fractal = MasterSquare(v2);
   if(range <= 0 || fractal <= 0)
      return(false);

   // octave: phan so nho nhat (fractal / 2^n) van phu duoc vung gia
   double sum = MathFloor(MathLog(fractal / range) / MathLog(2));
   double octave = fractal * MathPow(0.5, sum);
   double mn = MathFloor(v1 / octave) * octave;
   double mx;
   if(FixOctaveBug)
      mx = ((mn + octave) > v2) ? mn + octave : mn + (2 * octave);
   else
      mx = mn + (2 * octave);               // ban goc: thieu 'else'
   double box = mx - mn;

   // chon khung con (ca khung / nua khung / mot phan tu) chua vung gia -> 8/8 (finalH) va 0/8 (finalL)
   double x1 = 0, x2 = 0, x3 = 0, x4 = 0, x5 = 0, x6 = 0;
   double y1 = 0, y2 = 0, y3 = 0, y4 = 0, y5 = 0, y6 = 0;

   if(v1 >= (3 * box / 16 + mn) && v2 <= (9 * box / 16 + mn))  x2 = mn + box / 2;
   if(v1 >= (mn - box / 8) && v2 <= (5 * box / 8 + mn) && x2 == 0) x1 = mn + box / 2;
   if(v1 >= (mn + 7 * box / 16) && v2 <= (13 * box / 16 + mn)) x4 = mn + 3 * box / 4;
   if(v1 >= (mn + 3 * box / 8) && v2 <= (9 * box / 8 + mn) && x4 == 0) x5 = mx;
   if(v1 >= (mn + box / 8) && v2 <= (7 * box / 8 + mn) && x1 == 0 && x2 == 0 && x4 == 0 && x5 == 0) x3 = mn + 3 * box / 4;
   if((x1 + x2 + x3 + x4 + x5) == 0) x6 = mx;

   double finalH = x1 + x2 + x3 + x4 + x5 + x6;

   if(x1 > 0) y1 = mn;
   if(x2 > 0) y2 = mn + box / 4;
   if(x3 > 0) y3 = mn + box / 4;
   if(x4 > 0) y4 = mn + box / 2;
   if(x5 > 0) y5 = mn + box / 2;
   if(finalH > 0 && (y1 + y2 + y3 + y4 + y5) == 0) y6 = mn;

   double finalL = y1 + y2 + y3 + y4 + y5 + y6;
   double v45 = (finalH - finalL) / 8;        // mot "phan tam"
   if(v45 <= 0)
      return(false);

   // Cac muc khong doi so voi lan truoc thi khong can doi duong, chi doi nhan theo nen moi
   bool changed = (MathAbs(finalL - g_finalL) > Point / 2 || MathAbs(v45 - g_v45) > Point / 10 ||
                   ObjectFind(0, majName[0]) < 0);

   for(int i = 0; i < 13; i++)
     {
      double p = finalL + (i - 2) * v45;
      if(changed)
         PutLine(majName[i], p, majColor[i], 2, STYLE_SOLID);
      PutText(majName[i] + "_txt", majText[i], p, majColor[i]);
     }

   if(changed && ShowMinorLines)
      for(int j = 0; j < 36; j++)
        {
         bool half = (MathAbs(MathMod(MathAbs(minOff[j]), 1.0) - 0.5) < 0.001);
         PutLine(minName[j], finalL + minOff[j] * v45, SlateGray, 1, half ? STYLE_DOT : STYLE_SOLID);
        }

   g_finalL = finalL;
   g_v45 = v45;

   if(ShowComment)
      Comment("\n", "MURREY MATH THEO KHUNG THOI GIAN (XARD777)", "\n",
              "Dinh cao nhat = ", DoubleToString(v2, Digits), "\n",
              "Day thap nhat = ", DoubleToString(v1, Digits), "\n",
              "Bien do = ", DoubleToString(range, Digits), "\n",
              "Master Square = ", DoubleToString(fractal, 7), "\n",
              "Octave 8/8 = ", DoubleToString(finalH, Digits), "\n",
              "Octave 0/8 = ", DoubleToString(finalL, Digits), "\n",
              "Do rong 1/8 = ", DoubleToString(v45, Digits + 1), "\n",
              "Buoc dao chieu nho nhat (fractal/128) = ", DoubleToString(fractal / 128, 7));
   return(true);
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < 2)
      return(0);
   if(prev_calculated == 0)
      g_lastBar = 0;                       // lich su thay doi: tinh lai

   // cua so chi truot khi co nen moi nen cac tick khac khong can lam gi
   if(Time[0] != g_lastBar)
     {
      if(Calculate())
        {
         g_lastBar = Time[0];
         ChartRedraw();
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
