//+------------------------------------------------------------------+
//| USTEC_TrendRunner_v0_4_safety_public.mq5                         |
//| Educational research Expert Advisor for USTEC/Nasdaq CFDs.        |
//|                                                                  |
//| This file is provided for transparency and research review only.  |
//| It is not financial advice, not a signal, not a product, and not  |
//| approved for live or demo execution. Backtest results do not      |
//| guarantee future performance.                                     |
//+------------------------------------------------------------------+
#property strict
#property version   "0.401"
#property description "Educational USTEC/Nasdaq CFD trend-runner research sample. No profit guarantee."

#include <Trade/Trade.mqh>

input string          InpStrategyLabel        = "USTEC TrendRunner v0_4 safety public research";
input double          InpRiskPercent          = 0.50;
input int             InpMaxSpreadPoints      = 300;
input int             InpAtrPeriod            = 14;
input int             InpAdxPeriod            = 14;
input double          InpMinAdx               = 22.0;
input ENUM_TIMEFRAMES InpTrendTimeframe       = PERIOD_M15;
input int             InpFastEmaPeriod        = 21;
input int             InpSlowEmaPeriod        = 55;
input double          InpStopAtrMultiplier    = 2.0;
input double          InpTargetRiskMultiple   = 2.8;
input int             InpSessionStartHour     = 14;
input int             InpSessionEndHour       = 17;
input int             InpMaxTradesPerDay      = 2;
input int             InpCooldownBarsAfterLoss = 20;
input int             InpMinBarsBetweenTrades = 8;
input ulong           InpMagicNumber          = 8801004;
input int             InpDeviationPoints      = 30;
input bool            InpAllowLong            = true;
input bool            InpAllowShort           = false;
input string          InpExpectedSymbolContains = "USTEC";
input ENUM_TIMEFRAMES InpExpectedTimeframe    = PERIOD_M5;
input bool            InpAllowSymbolOverride  = false;
input bool            InpAllowTimeframeOverride = false;
input double          InpMaxActualRiskMultiplier = 1.05;

CTrade trade;

const bool PUBLIC_RESEARCH_LONG_ONLY = true;

int atr_handle = INVALID_HANDLE;
int adx_handle = INVALID_HANDLE;
int fast_ema_handle = INVALID_HANDLE;
int slow_ema_handle = INVALID_HANDLE;

datetime last_bar_time = 0;
datetime current_day_start = 0;
datetime cooldown_until = 0;
datetime last_trade_bar_time = 0;
int trades_today = 0;

datetime DayStart(const datetime value)
{
   MqlDateTime parts;
   TimeToStruct(value, parts);
   parts.hour = 0;
   parts.min = 0;
   parts.sec = 0;
   return StructToTime(parts);
}

bool ValidateSymbolAndTimeframe()
{
   if(StringLen(InpExpectedSymbolContains) > 0 &&
      StringFind(_Symbol, InpExpectedSymbolContains) < 0 &&
      !InpAllowSymbolOverride)
   {
      Print(InpStrategyLabel, ": invalid symbol guard. symbol=", _Symbol,
            " expected_contains=", InpExpectedSymbolContains);
      return false;
   }

   if(_Period != InpExpectedTimeframe && !InpAllowTimeframeOverride)
   {
      Print(InpStrategyLabel, ": invalid timeframe guard. period=", (int)_Period,
            " expected=", (int)InpExpectedTimeframe);
      return false;
   }

   return true;
}

bool ValidateTradeEnvironment()
{
   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   const double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   const double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   const double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   const int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   const int freeze_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   const long trade_mode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
   const long order_mode = SymbolInfoInteger(_Symbol, SYMBOL_ORDER_MODE);
   const long filling_mode = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);

   Print(InpStrategyLabel, ": symbol environment. symbol=", _Symbol,
         " period=", (int)_Period,
         " point=", DoubleToString(point, 10),
         " tick_size=", DoubleToString(tick_size, 10),
         " tick_value=", DoubleToString(tick_value, 10),
         " volume_min=", DoubleToString(min_volume, 8),
         " volume_max=", DoubleToString(max_volume, 8),
         " volume_step=", DoubleToString(step, 8),
         " stops_level=", stops_level,
         " freeze_level=", freeze_level,
         " trade_mode=", trade_mode,
         " order_mode=", order_mode,
         " filling_mode=", filling_mode);

   if(point <= 0.0 || min_volume <= 0.0 || max_volume <= 0.0 || step <= 0.0)
   {
      Print(InpStrategyLabel, ": rejected by invalid symbol volume/point properties.");
      return false;
   }

   if(max_volume < min_volume)
   {
      Print(InpStrategyLabel, ": rejected because max volume is below min volume.");
      return false;
   }

   if(trade_mode == SYMBOL_TRADE_MODE_DISABLED)
   {
      Print(InpStrategyLabel, ": rejected because symbol trade mode is disabled.");
      return false;
   }

   if(order_mode <= 0 || filling_mode <= 0)
   {
      Print(InpStrategyLabel, ": rejected because order/filling mode is unavailable.");
      return false;
   }

   return true;
}

bool IsNewBar()
{
   const datetime bar_time = iTime(_Symbol, _Period, 0);
   if(bar_time <= 0)
      return false;

   if(bar_time == last_bar_time)
      return false;

   last_bar_time = bar_time;
   return true;
}

bool GetBufferValue(const int handle, const int buffer, const int shift, double &value)
{
   double values[];
   ArraySetAsSeries(values, true);

   if(CopyBuffer(handle, buffer, shift, 1, values) != 1)
      return false;

   value = values[0];
   return true;
}

bool SessionAllowed()
{
   MqlDateTime now;
   TimeToStruct(TimeCurrent(), now);

   if(InpSessionStartHour == InpSessionEndHour)
      return true;

   if(InpSessionStartHour < InpSessionEndHour)
      return (now.hour >= InpSessionStartHour && now.hour < InpSessionEndHour);

   return (now.hour >= InpSessionStartHour || now.hour < InpSessionEndHour);
}

bool SpreadAllowed()
{
   const double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   if(point <= 0.0 || ask <= 0.0 || bid <= 0.0)
      return false;

   const int spread_points = (int)MathRound((ask - bid) / point);
   if(spread_points > InpMaxSpreadPoints)
      Print(InpStrategyLabel, ": rejected by spread. spread_points=", spread_points);

   return (spread_points <= InpMaxSpreadPoints);
}

int OpenPositionCount()
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;

      count++;
   }

   return count;
}

void RefreshTradesToday()
{
   const datetime today = DayStart(TimeCurrent());
   if(today != current_day_start)
   {
      current_day_start = today;
      trades_today = 0;
   }

   int count = 0;
   if(!HistorySelect(current_day_start, TimeCurrent()))
   {
      trades_today = 0;
      return;
   }

   const int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      const ulong deal = HistoryDealGetTicket(i);
      if(deal == 0)
         continue;

      if(HistoryDealGetString(deal, DEAL_SYMBOL) != _Symbol)
         continue;

      if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC) != InpMagicNumber)
         continue;

      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY) == DEAL_ENTRY_IN)
         count++;
   }

   trades_today = count;
}

int VolumeDigitsFromStep(const double step)
{
   for(int digits = 0; digits <= 8; digits++)
   {
      const double scaled = step * MathPow(10.0, digits);
      if(MathAbs(scaled - MathRound(scaled)) < 0.00000001)
         return digits;
   }

   return 8;
}

double NormalizeVolumeDown(const double volume)
{
   const double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   const double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(volume <= 0.0 || step <= 0.0 || max_volume <= 0.0)
      return 0.0;

   double capped = MathMin(volume, max_volume);
   double normalized = MathFloor((capped / step) + 0.00000001) * step;
   const int digits = VolumeDigitsFromStep(step);
   return NormalizeDouble(normalized, digits);
}

double LossForVolume(const ENUM_ORDER_TYPE order_type,
                     const double volume,
                     const double entry,
                     const double stop)
{
   double profit = 0.0;
   if(!OrderCalcProfit(order_type, _Symbol, volume, entry, stop, profit))
   {
      Print(InpStrategyLabel, ": OrderCalcProfit failed for volume=", DoubleToString(volume, 8));
      return -1.0;
   }

   return MathAbs(profit);
}

double VolumeForRisk(const ENUM_ORDER_TYPE order_type, const double entry, const double stop)
{
   const double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   const double risk_money = equity * InpRiskPercent / 100.0;
   const double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   const double max_allowed_risk = risk_money * InpMaxActualRiskMultiplier;

   if(risk_money <= 0.0 || min_volume <= 0.0 || step <= 0.0 || max_allowed_risk <= 0.0)
      return 0.0;

   const double loss_one_lot = LossForVolume(order_type, 1.0, entry, stop);
   if(loss_one_lot <= 0.0)
      return 0.0;

   const double raw_volume = risk_money / loss_one_lot;
   double volume = NormalizeVolumeDown(raw_volume);

   if(volume < min_volume)
   {
      const double min_volume_loss = LossForVolume(order_type, min_volume, entry, stop);
      if(min_volume_loss <= 0.0)
         return 0.0;

      if(min_volume_loss > max_allowed_risk)
      {
         Print(InpStrategyLabel, ": rejected min lot risk. min_volume=",
               DoubleToString(min_volume, 8),
               " actual_risk=", DoubleToString(min_volume_loss, 2),
               " allowed=", DoubleToString(max_allowed_risk, 2));
         return 0.0;
      }

      volume = NormalizeDouble(min_volume, VolumeDigitsFromStep(step));
   }

   const double actual_risk = LossForVolume(order_type, volume, entry, stop);
   if(actual_risk <= 0.0)
      return 0.0;

   if(actual_risk > max_allowed_risk)
   {
      Print(InpStrategyLabel, ": rejected actual risk. volume=",
            DoubleToString(volume, 8),
            " actual_risk=", DoubleToString(actual_risk, 2),
            " allowed=", DoubleToString(max_allowed_risk, 2));
      return 0.0;
   }

   return volume;
}

bool HasEnoughStopDistance(const double entry, const double stop, const double target)
{
   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   const int freeze_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);

   if(point <= 0.0)
      return false;

   const double min_distance = MathMax(stops_level, freeze_level) * point;
   if(MathAbs(entry - stop) < min_distance)
   {
      Print(InpStrategyLabel, ": rejected by stop distance. min_distance=", DoubleToString(min_distance, 10));
      return false;
   }

   if(MathAbs(entry - target) < min_distance)
   {
      Print(InpStrategyLabel, ": rejected by target distance. min_distance=", DoubleToString(min_distance, 10));
      return false;
   }

   return true;
}

int BuildSignal(double &atr_value)
{
   double adx = 0.0;
   double fast = 0.0;
   double slow = 0.0;

   if(!GetBufferValue(atr_handle, 0, 1, atr_value))
      return 0;

   if(!GetBufferValue(adx_handle, 0, 1, adx))
      return 0;

   if(!GetBufferValue(fast_ema_handle, 0, 1, fast))
      return 0;

   if(!GetBufferValue(slow_ema_handle, 0, 1, slow))
      return 0;

   if(atr_value <= 0.0 || adx < InpMinAdx)
      return 0;

   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, _Period, 0, 4, rates) < 4)
      return 0;

   const bool trend_up = (fast > slow);
   const bool trend_down = (fast < slow);
   const bool breakout_up = (rates[1].close > rates[2].high);
   const bool breakout_down = (rates[1].close < rates[2].low);

   if(InpAllowLong && trend_up && breakout_up)
      return 1;

   if(PUBLIC_RESEARCH_LONG_ONLY && trend_down && breakout_down)
   {
      Print(InpStrategyLabel, ": short signal rejected by long-only hard lock.");
      return 0;
   }

   if(InpAllowShort && trend_down && breakout_down)
      return -1;

   return 0;
}

bool OrderAcceptedByRetcode()
{
   const uint retcode = trade.ResultRetcode();
   const ulong deal = trade.ResultDeal();
   const ulong order = trade.ResultOrder();
   const string description = trade.ResultRetcodeDescription();

   Print(InpStrategyLabel, ": order result. retcode=", retcode,
         " deal=", deal,
         " order=", order,
         " description=", description);

   if((retcode == TRADE_RETCODE_DONE || retcode == TRADE_RETCODE_DONE_PARTIAL) && deal > 0)
      return true;

   if(retcode == TRADE_RETCODE_PLACED && order > 0)
      return true;

   Print(InpStrategyLabel, ": order rejected by retcode/deal validation.");
   return false;
}

bool PlaceSignalTrade(const int signal, const double atr_value)
{
   const int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   const double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(ask <= 0.0 || bid <= 0.0 || atr_value <= 0.0)
      return false;

   if(signal > 0)
   {
      const double entry = ask;
      const double stop = NormalizeDouble(entry - (InpStopAtrMultiplier * atr_value), digits);
      const double target = NormalizeDouble(entry + ((entry - stop) * InpTargetRiskMultiple), digits);

      if(!HasEnoughStopDistance(entry, stop, target))
         return false;

      const double volume = VolumeForRisk(ORDER_TYPE_BUY, entry, stop);
      if(volume <= 0.0)
         return false;

      if(trade.Buy(volume, _Symbol, entry, stop, target, "USTEC public research long") &&
         OrderAcceptedByRetcode())
      {
         last_trade_bar_time = last_bar_time;
         return true;
      }

      OrderAcceptedByRetcode();
      return false;
   }

   if(signal < 0)
   {
      if(PUBLIC_RESEARCH_LONG_ONLY)
      {
         Print(InpStrategyLabel, ": sell request rejected by long-only hard lock.");
         return false;
      }

      const double entry = bid;
      const double stop = NormalizeDouble(entry + (InpStopAtrMultiplier * atr_value), digits);
      const double target = NormalizeDouble(entry - ((stop - entry) * InpTargetRiskMultiple), digits);

      if(!HasEnoughStopDistance(entry, stop, target))
         return false;

      const double volume = VolumeForRisk(ORDER_TYPE_SELL, entry, stop);
      if(volume <= 0.0)
         return false;

      if(trade.Sell(volume, _Symbol, entry, stop, target, "USTEC public research short") &&
         OrderAcceptedByRetcode())
      {
         last_trade_bar_time = last_bar_time;
         return true;
      }

      OrderAcceptedByRetcode();
      return false;
   }

   return false;
}

int OnInit()
{
   if(!ValidateSymbolAndTimeframe())
      return INIT_FAILED;

   if(!ValidateTradeEnvironment())
      return INIT_FAILED;

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpDeviationPoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   if(PUBLIC_RESEARCH_LONG_ONLY && InpAllowShort)
      Print(InpStrategyLabel, ": InpAllowShort is ignored by long-only hard lock.");

   atr_handle = iATR(_Symbol, _Period, InpAtrPeriod);
   adx_handle = iADX(_Symbol, _Period, InpAdxPeriod);
   fast_ema_handle = iMA(_Symbol, InpTrendTimeframe, InpFastEmaPeriod, 0, MODE_EMA, PRICE_CLOSE);
   slow_ema_handle = iMA(_Symbol, InpTrendTimeframe, InpSlowEmaPeriod, 0, MODE_EMA, PRICE_CLOSE);

   if(atr_handle == INVALID_HANDLE ||
      adx_handle == INVALID_HANDLE ||
      fast_ema_handle == INVALID_HANDLE ||
      slow_ema_handle == INVALID_HANDLE)
   {
      Print(InpStrategyLabel, ": failed to create indicator handles.");
      return INIT_FAILED;
   }

   current_day_start = DayStart(TimeCurrent());
   Print(InpStrategyLabel, " initialized. Educational research sample only.");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(atr_handle != INVALID_HANDLE)
      IndicatorRelease(atr_handle);
   if(adx_handle != INVALID_HANDLE)
      IndicatorRelease(adx_handle);
   if(fast_ema_handle != INVALID_HANDLE)
      IndicatorRelease(fast_ema_handle);
   if(slow_ema_handle != INVALID_HANDLE)
      IndicatorRelease(slow_ema_handle);
}

void OnTick()
{
   if(!IsNewBar())
      return;

   RefreshTradesToday();

   if(TimeCurrent() < cooldown_until)
      return;

   if(last_trade_bar_time > 0)
   {
      const int elapsed = iBarShift(_Symbol, _Period, last_trade_bar_time, true);
      if(elapsed >= 0 && elapsed < InpMinBarsBetweenTrades)
         return;
   }

   if(trades_today >= InpMaxTradesPerDay)
      return;

   if(OpenPositionCount() > 0)
      return;

   if(!SessionAllowed())
      return;

   if(!SpreadAllowed())
      return;

   double atr_value = 0.0;
   const int signal = BuildSignal(atr_value);
   if(signal == 0)
      return;

   PlaceSignalTrade(signal, atr_value);
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return;

   if(!HistoryDealSelect(trans.deal))
      return;

   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol)
      return;

   if((ulong)HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != InpMagicNumber)
      return;

   const ENUM_DEAL_ENTRY entry_type = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   if(entry_type != DEAL_ENTRY_OUT && entry_type != DEAL_ENTRY_INOUT)
      return;

   const double pnl = HistoryDealGetDouble(trans.deal, DEAL_PROFIT) +
                      HistoryDealGetDouble(trans.deal, DEAL_COMMISSION) +
                      HistoryDealGetDouble(trans.deal, DEAL_SWAP);

   if(pnl < 0.0 && InpCooldownBarsAfterLoss > 0)
      cooldown_until = TimeCurrent() + (PeriodSeconds(_Period) * InpCooldownBarsAfterLoss);
}
