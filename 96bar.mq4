//+------------------------------------------------------------------+
//|                                                    BuySellStop.mq4|
//|                                  Copyright 2023, Example, Inc.    |
//|                                              https://example.com/ |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
input double slippage = 2;
double lotSize = 0.1;
int MagicNumber = 003;
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
bool sellStopOrderSent0 = false;
bool buyStopOrderSent0 = false;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool buy1 = false;
bool buy2 = false;
bool buy3 = false;
bool buy4 = false;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double EMA5;
double EMA90;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int sumUp = 0;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool flag1 = false;
bool flag2 = false;
bool flag3 = false;
bool flag4 = false;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int countBars = 0;
   bool flagPrice = false;
   double maxPriceBar = 0;
   double firstPriceBar = 0;
   double prevClose = iLow(_Symbol, PERIOD_CURRENT, 1);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool longCondition = (EMA5 > EMA90) && (EMA5 - EMA90 > 0.0001);
   bool shortCondition = (EMA5 < EMA90) && (EMA90 - EMA5 > 0.0001);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   EMA5 = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
   EMA90 = iMA(_Symbol, _Period, 90, 0, MODE_EMA, PRICE_CLOSE, 0);

   flag1 = (EMA5 > EMA90 && Bid > EMA90);
   flag2 = (EMA5 < EMA90);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(flag1)
     {
      flagPrice = true;
      for(int q = 1; q <= 500; q++)
        {
         double ema5_i = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE, q);
         double ema90_i = iMA(_Symbol, _Period, 90, 0, MODE_EMA, PRICE_CLOSE, q);
         if(ema5_i > ema90_i)
           {
            countBars++;
            if(countBars == 96)
              {
               flag3 = true;
               break;
              }
           }
         else
           {
            countBars = 0;
            flag3 = false;

            flag4 = false;
            sumUp = 0;
            maxPriceBar = 0;
            firstPriceBar = 0;
            buy1 = false;
            break;
           }
         if(flagPrice)
           {
            double currentPrice = NormalizeDouble(High[q], Digits);
            if(maxPriceBar < currentPrice)
              {
               maxPriceBar = currentPrice;
              }
            if(firstPriceBar == 0)
              {
               firstPriceBar = currentPrice;
              }
           }
        }
      if(flag3 && flagPrice)
        {
         sumUp = (maxPriceBar - firstPriceBar) / Point;
        }
     }
   else
     {
      flagPrice = false;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double totalPips = 0;
   for(int e = OrdersTotal() - 1; e >= 0; e--)
     {
      if(OrderSelect(e, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
           {
            double profit = OrderProfit();
            double symbolPoint = SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_SIZE);
            double pips = profit / symbolPoint;
            totalPips += pips / 100000;
           }
        }
     }


//+------------------------------------------------------------------+
//! Начало торговли
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//? Открываем сделку когда ема5 выше 90й в течении 96 баров (8часов на М5)
//+------------------------------------------------------------------+
   if(flag1 && flag3 && !buy1 && prevClose > EMA90)
     {
      OrderSend(_Symbol, OP_SELL, lotSize, Bid, 3, 0, 0, "EMA cross", 123, 0, Green);
      buy1 = true;
      flag4 = true;
     }
//+------------------------------------------------------------------+
//? Устанавливаем SellLimit на ближайший максимум
//+------------------------------------------------------------------+
   if(flag4 && sumUp >= 100 && !buy2)
     {
      OrderSend(_Symbol, OP_SELLLIMIT, lotSize, maxPriceBar, 3, 0, 0, "EMA cross", 123, 0, Green);
      buy2 = true;
     }
   if(sumUp == 0 && buy2)
     {
      buy2 = false;
     }

   if(shortCondition)
     {

     }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int totalPositions = OrdersTotal();

   double totalLotsSell = 0;
   double totalLotsBuy = 0;

   for(int i = 0; i < totalPositions; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderType() == OP_SELL)
           {
            totalLotsSell += OrderLots();
           }
         if(OrderType() == OP_BUY)
           {
            totalLotsBuy += OrderLots();
           }
        }
     }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double high = iHigh(Symbol(), PERIOD_CURRENT, 0);
   double low = iLow(Symbol(), PERIOD_CURRENT, 0);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((high - low) > 300 * Point && !buy3)
     {
      OrderSend(_Symbol, OP_BUY, totalLotsSell, Ask, 3, 0, 0, "EMA cross", 01, 0, Green);
      buy3 = true;
     }
//  if((high - low) > 300 * Point && !buy4 && buy3)
//    {
//     OrderSend(_Symbol, OP_BUY, totalLotsSell - totalLotsBuy, Ask, 3, 0, 0, "EMA cross", 01, 0, Green);
//     buy4 = true;
//    }
// if (totalPips <= -1000 && !buy4) {
//     OrderSend(_Symbol, OP_BUY, totalLots, Ask, 3, 0, 0, "EMA cross", 123, 0, Green);
//    buy4 = true;
// }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(totalPips >= 25)
     {
      double current_priceB = MarketInfo(Symbol(), MODE_BID);
      double current_priceA = MarketInfo(Symbol(), MODE_ASK);
      for(int ci = OrdersTotal() - 1; ci >= 0; ci--)
        {
         if(OrderSelect(ci, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() == _Symbol) // Убедитесь, что это сделка для текущего символа
              {
               if(OrderType() == OP_BUY)
                 {
                  bool closedA = OrderClose(OrderTicket(), OrderLots(), current_priceB, 10, clrRed);
                  buy4 = false;
                  buy3 = false;
                  flag4 = false;
                  if(closedA)
                    {Print("Trade closed successfully!");}
                  else
                    {Print("Failed to close trade! Error code: ", GetLastError());}
                 }
               if(OrderType() == OP_SELL)
                 {
                  bool closedB = OrderClose(OrderTicket(), OrderLots(), current_priceA, 10, clrRed);
                  buy4 = false;
                  buy3 = false;
                  flag4 = false;
                  if(closedB)
                    {Print("Trade closed successfully!");}
                  else
                    {Print("Failed to close trade! Error code: ", GetLastError());}
                 }

              }
           }
        }

      for(int cl2 = OrdersTotal() - 1; cl2 >= 0; cl2--)
        {
         if(OrderSelect(cl2, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
              {
               bool closedE = OrderDelete(OrderTicket());
               if(closedE)
                 {Print("Order closed successfully!");}
               else
                 {Print("Failed to close Order! Error code: ", GetLastError());}
              }
           }
        }
     }


   Comment("flag1: ", flag1, " flag2: ", flag2, " flag3: ", flag3, " countBars: ", countBars, " maxPriceBar: ", maxPriceBar, " sumUp: ", sumUp, " totalPips: ", totalPips, " flag4: ", flag4, " buy1: ", buy1, " totalLotsSell: ", totalLotsSell, " totalLotsBuy: ", totalLotsBuy);

  }
//+------------------------------------------------------------------+
