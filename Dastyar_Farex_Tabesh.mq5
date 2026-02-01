//+------------------------------------------------------------------+
//| Expert Advisor : Dastyar Farex Tabesh                            |
//| Phase 1 : Indicator Detection & Logging                          |
//| Platform : MetaTrader 5 (MQL5 Standard)                          |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property description "اکسپرت معاملاتی متاتریدر 5 کاملا فارسی یک استراتزی مبتنی بر اندیکاتور و هوش مصنوعی"

//-------------------- INPUTS (فارسی) -------------------------------

// RSI
input int      RSI_Period          = 14;     // دوره RSI
input double   RSI_OverBought      = 70.0;   // اشباع خرید RSI
input double   RSI_OverSold        = 30.0;   // اشباع فروش RSI

// Bollinger Bands
input int      BB_Period           = 20;     // دوره بولینگر باند
input double   BB_Deviation        = 2.0;    // انحراف معیار بولینگر
input ENUM_APPLIED_PRICE BB_Price  = PRICE_CLOSE; // قیمت مبنا بولینگر

// Moving Average
input int      MA_Period           = 50;     // دوره مووینگ اوریج
input ENUM_MA_METHOD MA_Method     = MODE_EMA; // نوع MA
input ENUM_APPLIED_PRICE MA_Price  = PRICE_CLOSE; // قیمت MA

// Ichimoku
input int      Ichi_Tenkan          = 9;     // تنکان
input int      Ichi_Kijun           = 26;    // کیجون
input int      Ichi_SenkouB         = 52;    // سنکو B

// ATR
input int      ATR_Period           = 14;    // دوره ATR

//-------------------- GLOBAL HANDLES --------------------------------
int rsiHandle;
int bbHandle;
int maHandle;
int atrHandle;
int ichiHandle;

//-------------------- BUFFERS ---------------------------------------
double rsiBuffer[];

double bbUpper[];
double bbMiddle[];
double bbLower[];

double maBuffer[];

double atrBuffer[];

double tenkan[];
double kijun[];
double senkouA[];
double senkouB[];
double chikou[];

//+------------------------------------------------------------------+
int OnInit()
{
//--- RSI (پنجره جدا)
rsiHandle = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);
ChartIndicatorAdd(0, 1, rsiHandle); // subwindow = 1

   //--- Bollinger Bands
   bbHandle = iBands(_Symbol, _Period, BB_Period, 0, BB_Deviation, BB_Price);
   ChartIndicatorAdd(0, 0, bbHandle);

   //--- Moving Average
   maHandle = iMA(_Symbol, _Period, MA_Period, 0, MA_Method, MA_Price);
   ChartIndicatorAdd(0, 0, maHandle);

//--- ATR (پنجره جدا)
atrHandle = iATR(_Symbol, _Period, ATR_Period);
ChartIndicatorAdd(0, 2, atrHandle); // subwindow = 2

   //--- Ichimoku
   ichiHandle = iIchimoku(_Symbol, _Period,
                          Ichi_Tenkan,
                          Ichi_Kijun,
                          Ichi_SenkouB);
   ChartIndicatorAdd(0, 0, ichiHandle);

   Print("✅ اکسپرت با موفقیت مقداردهی اولیه شد");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnTick()
{
   int shift = 1; // آخرین کندل بسته‌شده (نه در حال شکل‌گیری)

   //================ RSI ==================
   CopyBuffer(rsiHandle, 0, shift, 1, rsiBuffer);
   double rsiValue = rsiBuffer[0];

   if(rsiValue >= RSI_OverBought)
      Print("📌 RSI اشباع خرید | مقدار: ", rsiValue);
   else if(rsiValue <= RSI_OverSold)
      Print("📌 RSI اشباع فروش | مقدار: ", rsiValue);

   //================ Bollinger Bands ==================
   CopyBuffer(bbHandle, 0, shift, 1, bbUpper);
   CopyBuffer(bbHandle, 1, shift, 1, bbMiddle);
   CopyBuffer(bbHandle, 2, shift, 1, bbLower);

   Print("📌 BB Upper:", bbUpper[0],
         " | Middle:", bbMiddle[0],
         " | Lower:", bbLower[0]);

   //================ Moving Average ==================
   CopyBuffer(maHandle, 0, shift, 1, maBuffer);
   Print("📌 MA مقدار:", maBuffer[0]);

   //================ ATR ==================
   CopyBuffer(atrHandle, 0, shift, 1, atrBuffer);
   Print("📌 ATR دامنه نوسان:", atrBuffer[0]);

   //================ Ichimoku ==================
   CopyBuffer(ichiHandle, 0, shift, 1, tenkan);
   CopyBuffer(ichiHandle, 1, shift, 1, kijun);
   CopyBuffer(ichiHandle, 2, shift, 1, senkouA);
   CopyBuffer(ichiHandle, 3, shift, 1, senkouB);
   CopyBuffer(ichiHandle, 4, shift, 1, chikou);

   Print("📌 Ichimoku | Tenkan:", tenkan[0],
         " | Kijun:", kijun[0],
         " | SenkouA:", senkouA[0],
         " | SenkouB:", senkouB[0],
         " | Chikou:", chikou[0]);

   // تشخیص وضعیت ابر کومو
   if(senkouA[0] > senkouB[0])
      Print("☁️ کومو صعودی");
   else
      Print("☁️ کومو نزولی");
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(rsiHandle);
   IndicatorRelease(bbHandle);
   IndicatorRelease(maHandle);
   IndicatorRelease(atrHandle);
   IndicatorRelease(ichiHandle);

   Print("🛑 اکسپرت متوقف شد");
}
//+ مرحله اول تمام شد در این مرحله ما اندیکاتور های مورد استفاده را تعریف کردیم و در مرله بعد سناریو و گام های بعدی را اجرا میکنیم از این جا 
//+------------------------------------------------------------------+
