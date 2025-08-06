//+------------------------------------------------------------------+
//| R&B - Quantum Yield Bot | v1.22 | HUD PRO ESTABLE                |
//+------------------------------------------------------------------+
#property copyright "© 2025 Jere Masih"
#property version   "1.22"
#property strict

//------------------ Inputs visuales HUD ----------------------------
input color  PanelBgColor      = clrBlack;
input color  PanelFontMain     = clrWhite;
input color  PanelFontTitle    = clrWhite;
input color  PanelFontAccent   = clrAqua;
input color  BuyButtonColor    = clrAqua;
input color  SellButtonColor   = clrRed;
input color  CloseButtonColor  = clrYellow;
input color  PauseButtonColor  = clrGray;
input color  OnlineButtonColor = clrLime;
input int    PanelMarginX      = 15;
input int    PanelMarginY      = 15;
input int    PanelWidth        = 540;
input int    PanelHeight       = 175;
input int    TitleFontSize     = 20;
input int    MainFontSize      = 14;
input int    TFLineFontSize    = 15;
input int    LabelSpacing      = 22;
input int    ButtonWidth       = 82;
input int    ButtonHeight      = 28;
input int    ButtonSpacing     = 8;

//------------------ Inputs de trading y estrategia -----------------
input int    FastEMAPeriod        = 50;
input int    SlowEMAPeriod        = 200;
input int    MinFramesAligned     = 3;
input ENUM_TIMEFRAMES WeightTF    = PERIOD_H1;
input ENUM_TIMEFRAMES ExecTF      = PERIOD_M15;
enum RiskType {MONEY, PERCENT};
input RiskType RiskMode           = MONEY;
input double SL_Money             = 300.0;
input double TP_Money             = 300.0;
input double SL_Pct               = 1.0;
input double TP_Pct               = 1.5;
input bool   UseTrail             = true;
input double TrailStartDollars    = 10.0;
input double TrailStepDollars     = 5.0;
input bool   AllowCounterTrend    = false;
input int    MaxSpreadPoints      = 30;
input int    MaxSlippagePoints    = 5;
input int    MaxCandleRangePoints = 500;
input double TradeLotSize         = 0.1;
input int    TradesPerSignal      = 1;

//------------------ Timeframes y handles EMA -----------------------
ENUM_TIMEFRAMES timeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};
string tf_names[] = {"M1", "M5", "M15", "H1", "H4", "D1"};
int fastEMAHandles[6];
int slowEMAHandles[6];

double onePoint;
double tickValue;

#define OBJ_PANEL_MAIN   "RBQY_PANEL"
#define OBJ_BTN_ONLINE   "RBQY_BTN_ONLINE"
#define OBJ_BTN_PAUSED   "RBQY_BTN_PAUSED"
#define OBJ_BTN_BUY      "RBQY_BTN_BUY"
#define OBJ_BTN_SELL     "RBQY_BTN_SELL"
#define OBJ_BTN_CLOSE    "RBQY_BTN_CLOSE"
#define OBJ_LABEL_PREFIX "RBQY_LABEL_"

bool robotOnline = true;
datetime last_update_time = 0;

//+------------------------------------------------------------------+
//| FUNCIONES DE TRADING NATIVAS (sin CTrade, ni includes)           |
//+------------------------------------------------------------------+
bool OpenBuyOrder(double lots, double price, double sl, double tp)
  {
   MqlTradeRequest req; MqlTradeResult res;
   ZeroMemory(req); ZeroMemory(res);
   req.action = TRADE_ACTION_DEAL; req.symbol = _Symbol;
   req.volume = lots; req.type = ORDER_TYPE_BUY;
   req.price = price; req.sl = sl; req.tp = tp;
   req.deviation = MaxSlippagePoints; req.type_filling = ORDER_FILLING_IOC;
   return OrderSend(req, res) && res.retcode == 10009;
  }

bool OpenSellOrder(double lots, double price, double sl, double tp)
  {
   MqlTradeRequest req; MqlTradeResult res;
   ZeroMemory(req); ZeroMemory(res);
   req.action = TRADE_ACTION_DEAL; req.symbol = _Symbol;
   req.volume = lots; req.type = ORDER_TYPE_SELL;
   req.price = price; req.sl = sl; req.tp = tp;
   req.deviation = MaxSlippagePoints; req.type_filling = ORDER_FILLING_IOC;
   return OrderSend(req, res) && res.retcode == 10009;
  }

bool ModifyPositionSLTP(ulong ticket, double sl, double tp)
  {
   MqlTradeRequest req; MqlTradeResult res;
   ZeroMemory(req); ZeroMemory(res);
   req.action = TRADE_ACTION_SLTP; req.position = ticket; req.symbol = _Symbol;
   req.sl = sl; req.tp = tp;
   return OrderSend(req, res) && res.retcode == 10009;
  }

void CloseAllOrders()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         string symbol = PositionGetString(POSITION_SYMBOL);
         int type = (int)PositionGetInteger(POSITION_TYPE);
         double lots = PositionGetDouble(POSITION_VOLUME);
         if(type == POSITION_TYPE_BUY)
            OpenSellOrder(lots, SymbolInfoDouble(symbol, SYMBOL_BID), 0, 0);
         else
            OpenBuyOrder(lots, SymbolInfoDouble(symbol, SYMBOL_ASK), 0, 0);
        }
     }
  }

//+------------------------------------------------------------------+
//| Inicialización                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   onePoint  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   for (int i = 0; i < ArraySize(timeframes); i++)
     {
      fastEMAHandles[i] = iMA(_Symbol, timeframes[i], FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
      slowEMAHandles[i] = iMA(_Symbol, timeframes[i], SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if (fastEMAHandles[i] == INVALID_HANDLE || slowEMAHandles[i] == INVALID_HANDLE)
        {
         Print("Error creating EMA handles on ", EnumToString(timeframes[i]));
         return(INIT_FAILED);
        }
     }
   DrawVisualPanel();
   EventSetTimer(1);
   ChartRedraw();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   for(int i=0; i<ArraySize(timeframes); i++)
     {
      if(fastEMAHandles[i]!=INVALID_HANDLE)  IndicatorRelease(fastEMAHandles[i]);
      if(slowEMAHandles[i]!=INVALID_HANDLE)  IndicatorRelease(slowEMAHandles[i]);
      ObjectDelete(0, OBJ_LABEL_PREFIX + tf_names[i]);
     }
   ObjectDelete(0, OBJ_PANEL_MAIN);
   ObjectDelete(0, OBJ_BTN_ONLINE);
   ObjectDelete(0, OBJ_BTN_PAUSED);
   ObjectDelete(0, OBJ_BTN_BUY);
   ObjectDelete(0, OBJ_BTN_SELL);
   ObjectDelete(0, OBJ_BTN_CLOSE);
   ObjectDelete(0, "RBQY_BALANCE");
   ObjectDelete(0, "RBQY_EQUITY");
   ObjectDelete(0, "RBQY_PROFIT");
   ObjectDelete(0, "RBQY_WEIGHTED_TF");
   ObjectDelete(0, "RBQY_EXEC_TF");
   ObjectDelete(0, "RBQY_TITLE");
   ObjectDelete(0, "RBQY_TFS");
  }

//+------------------------------------------------------------------+
//| Timer: Actualiza visual                                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   DrawVisualPanel();
   last_update_time = TimeCurrent();
  }

//+------------------------------------------------------------------+
//| Dibuja el panel visual PRO                                       |
//+------------------------------------------------------------------+
void DrawVisualPanel()
  {
   int px = PanelMarginX;
   int py = PanelMarginY;
   int w  = PanelWidth;
   int h  = PanelHeight;

   // Fondo principal
   if (ObjectFind(0, OBJ_PANEL_MAIN) < 0)
      ObjectCreate(0, OBJ_PANEL_MAIN, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, OBJ_PANEL_MAIN, OBJPROP_XDISTANCE, px);
   ObjectSetInteger(0, OBJ_PANEL_MAIN, OBJPROP_YDISTANCE, py);
   ObjectSetInteger(0, OBJ_PANEL_MAIN, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, OBJ_PANEL_MAIN, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, OBJ_PANEL_MAIN, OBJPROP_BGCOLOR, PanelBgColor);
   ObjectSetInteger(0, OBJ_PANEL_MAIN, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, OBJ_PANEL_MAIN, OBJPROP_BORDER_TYPE, 1);

   // --- Textos alineados por fila
   int tx = px + 14, ty = py + 16;
   DrawLabel("RBQY_TITLE", tx, ty, TitleFontSize, "R&B Quantum Yield Robot", PanelFontTitle);
   ty += TitleFontSize + 2;
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit  = AccountInfoDouble(ACCOUNT_PROFIT);

   DrawLabel("RBQY_BALANCE", tx, ty, MainFontSize, StringFormat("Balance: $%.2f  Equity: $%.2f", balance, equity), PanelFontMain);
   ty += MainFontSize + 1;
   DrawLabel("RBQY_PROFIT", tx, ty, MainFontSize, StringFormat("P/L: $%.2f", profit), profit >= 0 ? clrLime : clrRed);
   ty += MainFontSize + 6;

   // --- Timeframes con flechas y colores (NO se superponen)
   int tfsx = tx, tfsy = ty;
   int tfblock = 0;
   for (int i = 0; i < ArraySize(tf_names); i++)
   {
      string arrow = (GetTFTrendState(i) == 1) ? "↑" : (GetTFTrendState(i) == -1) ? "↓" : "-";
      color tfcol = (timeframes[i] == WeightTF) ? clrAqua :
                    (timeframes[i] == ExecTF) ? clrYellow :
                    (GetTFTrendState(i) == 1) ? clrLime :
                    (GetTFTrendState(i) == -1) ? clrRed : PanelFontMain;
      DrawLabel(OBJ_LABEL_PREFIX + tf_names[i], tfsx + tfblock * 48, tfsy, TFLineFontSize,
                tf_names[i] + " " + arrow, tfcol);
      tfblock++;
   }
   ty += TFLineFontSize + 6;

   // --- Weighted y Execution
   DrawLabel("RBQY_WEIGHTED_TF", tx, ty, MainFontSize, StringFormat("Weighted TF: %s", EnumToString(WeightTF)), clrAqua);
   DrawLabel("RBQY_EXEC_TF", tx + 210, ty, MainFontSize, StringFormat("Execution TF: %s", EnumToString(ExecTF)), clrYellow);

   // --- Botones alineados y textos visibles
   int btnY = py + h - ButtonHeight - 12;
   int btnX = tx;
   DrawButton(OBJ_BTN_ONLINE,  btnX, btnY, ButtonWidth, ButtonHeight, "ONLINE",  OnlineButtonColor, clrBlack, robotOnline);
   btnX += ButtonWidth + ButtonSpacing;
   DrawButton(OBJ_BTN_PAUSED,  btnX, btnY, ButtonWidth, ButtonHeight, "PAUSED",  PauseButtonColor, clrBlack, !robotOnline);
   btnX += ButtonWidth + ButtonSpacing;
   DrawButton(OBJ_BTN_BUY,     btnX, btnY, ButtonWidth, ButtonHeight, "BUY",     BuyButtonColor, clrBlack, false);
   btnX += ButtonWidth + ButtonSpacing;
   DrawButton(OBJ_BTN_SELL,    btnX, btnY, ButtonWidth, ButtonHeight, "SELL",    SellButtonColor, clrWhite, false);
   btnX += ButtonWidth + ButtonSpacing;
   DrawButton(OBJ_BTN_CLOSE,   btnX, btnY, ButtonWidth, ButtonHeight, "CLOSE ALL", CloseButtonColor, clrBlack, false);
  }

//+------------------------------------------------------------------+
//| Dibuja un botón con texto legible                                |
//+------------------------------------------------------------------+
void DrawButton(string name, int x, int y, int w, int h, string text, color bgcolor, color fg, bool active)
  {
   if (ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgcolor);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, fg);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 13);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, active ? 2 : 1); // borde
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//| Dibuja texto (etiqueta) alineado                                 |
//+------------------------------------------------------------------+
void DrawLabel(string name, int x, int y, int fs, string text, color fg)
  {
   if (ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fs);
   ObjectSetInteger(0, name, OBJPROP_COLOR, fg);
  }

//+------------------------------------------------------------------+
//| Botones: lógica                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if (id == CHARTEVENT_OBJECT_CLICK)
     {
      if (sparam == OBJ_BTN_ONLINE)  { robotOnline = true;   DrawVisualPanel(); }
      if (sparam == OBJ_BTN_PAUSED)  { robotOnline = false;  DrawVisualPanel(); }
      if (sparam == OBJ_BTN_BUY)
         OpenBuyOrder(TradeLotSize, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0);
      if (sparam == OBJ_BTN_SELL)
         OpenSellOrder(TradeLotSize, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0);
      if (sparam == OBJ_BTN_CLOSE)
         CloseAllOrders();
     }
  }

//+------------------------------------------------------------------+
//| Detección robusta de tendencia por TF (para flechas)             |
//+------------------------------------------------------------------+
int GetTFTrendState(int idx)
  {
   double fast[1], slow[1];
   int copiedFast = CopyBuffer(fastEMAHandles[idx], 0, 0, 1, fast);
   int copiedSlow = CopyBuffer(slowEMAHandles[idx], 0, 0, 1, slow);
   if (copiedFast != 1 || copiedSlow != 1) return 0;
   if (fast[0] > slow[0])  return 1;
   if (fast[0] < slow[0])  return -1;
   return 0;
  }

//+------------------------------------------------------------------+
//| Detección robusta de tendencia global                            |
//+------------------------------------------------------------------+
int GetTrendState()
  {
   int bullishCount = 0;
   int bearishCount = 0;
   bool weightBullish = false;
   bool weightBearish = false;
   for (int i = 0; i < ArraySize(timeframes); i++)
   {
      double fast[1], slow[1];
      int copiedFast = CopyBuffer(fastEMAHandles[i], 0, 0, 1, fast);
      int copiedSlow = CopyBuffer(slowEMAHandles[i], 0, 0, 1, slow);
      if (copiedFast != 1 || copiedSlow != 1)
         continue;
      if (fast[0] > slow[0])
      {
         bullishCount++;
         if (timeframes[i] == WeightTF) weightBullish = true;
      }
      else if (fast[0] < slow[0])
      {
         bearishCount++;
         if (timeframes[i] == WeightTF) weightBearish = true;
      }
   }
   if (bullishCount >= MinFramesAligned && weightBullish)
      return 1;
   else if (bearishCount >= MinFramesAligned && weightBearish)
      return -1;
   else
      return 0;
  }

//+------------------------------------------------------------------+
//| Confirmación de vela                                             |
//+------------------------------------------------------------------+
bool ConfirmCandle(int trend)
  {
   double openC  = iOpen(_Symbol, ExecTF, 1);
   double closeC = iClose(_Symbol, ExecTF, 1);
   int rangePts = (int)MathAbs((closeC-openC)/onePoint);
   if(rangePts > MaxCandleRangePoints) return(false);
   if(trend==1 && closeC>openC) return(true);
   if(trend==-1 && closeC<openC) return(true);
   return(false);
  }

//+------------------------------------------------------------------+
//| Revisa si existe posición opuesta                                |
//+------------------------------------------------------------------+
bool HasOppositePosition(int trend)
  {
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         string sym = PositionGetString(POSITION_SYMBOL);
         int type = (int)PositionGetInteger(POSITION_TYPE);
         if(sym==_Symbol)
           {
            if((trend==1 && type==POSITION_TYPE_SELL) ||
               (trend==-1 && type==POSITION_TYPE_BUY))
               return true;
           }
        }
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Ejecución de órdenes                                             |
//+------------------------------------------------------------------+
void ExecuteOrder(int trend)
  {
   double price = (trend==1 ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID));
   double slPts, tpPts;

   if(RiskMode==MONEY)
     {
      slPts = SL_Money / (TradeLotSize * tickValue);
      tpPts = TP_Money / (TradeLotSize * tickValue);
     }
   else
     {
      double bal = AccountInfoDouble(ACCOUNT_BALANCE);
      slPts = (SL_Pct/100.0 * bal) / (TradeLotSize * tickValue);
      tpPts = (TP_Pct/100.0 * bal) / (TradeLotSize * tickValue);
     }

   double sl = (trend==1 ? price - slPts*onePoint : price + slPts*onePoint);
   double tp = (trend==1 ? price + tpPts*onePoint : price - tpPts*onePoint);

   for(int i=0; i<TradesPerSignal; i++)
     {
      if(trend==1)
         OpenBuyOrder(TradeLotSize, price, sl, tp);
      else
         OpenSellOrder(TradeLotSize, price, sl, tp);
     }
  }

//+------------------------------------------------------------------+
//| Trailing Stop individual por trade (dólares)                     |
//+------------------------------------------------------------------+
void ApplyTrailingPerTradeDollars()
{
   for(int i=0; i<PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         int type = (int)PositionGetInteger(POSITION_TYPE);
         double currPrice = SymbolInfoDouble(_Symbol, (type==POSITION_TYPE_BUY) ? SYMBOL_BID : SYMBOL_ASK);
         double oldSL = PositionGetDouble(POSITION_SL);
         double profitDollars = PositionGetDouble(POSITION_PROFIT);

         if(profitDollars > TrailStartDollars)
         {
            double newSL;
            if(type == POSITION_TYPE_BUY)
               newSL = currPrice - (TrailStepDollars / tickValue) * onePoint;
            else
               newSL = currPrice + (TrailStepDollars / tickValue) * onePoint;

            if((type==POSITION_TYPE_BUY && (oldSL < newSL || oldSL==0)) ||
               (type==POSITION_TYPE_SELL && (oldSL > newSL || oldSL==0)))
            {
               ModifyPositionSLTP(ticket, newSL, PositionGetDouble(POSITION_TP));
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Lógica de trading principal del bot                              |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime lastTime=0;
   datetime t = iTime(_Symbol, _Period, 0);
   if(t==lastTime) return;
   lastTime = t;

   if(!robotOnline) return;
   if((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpreadPoints) return;

   int trend = GetTrendState();
   if(trend==0) return;
   if(!ConfirmCandle(trend)) return;
   if(!AllowCounterTrend && HasOppositePosition(trend)) return;
   ExecuteOrder(trend);
   if(UseTrail) ApplyTrailingPerTradeDollars();
  }

