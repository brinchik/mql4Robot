//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double slippage = 2;
double lotsize = 0.1;
int MagicNumber = 03333;
datetime currentTime;

bool hasPosition = false;
bool buyStopOrderSentFirstBuy = false;
bool sellStopOrderSentFirstSell = false;


datetime last_candle_time;
datetime prev_day_start_time;
int last_candle_index;
int prev_day_index;
int prev_day_of_week;
double prevDayHight;
double prevDayLow;
double prevDayClose;
double prevDayOpen;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   currentTime = TimeCurrent();
   int ordersTotal = OrdersTotal();







//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double ema5 = iMA(_Symbol, PERIOD_D1, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ema90 = iMA(_Symbol, PERIOD_D1, 90, 0, MODE_EMA, PRICE_CLOSE, 0);







//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ordersTotal == 0)
     {
      hasPosition = false;
     }
   else
     {
      for(int i = 0; i < ordersTotal; i++)
        {
         // Получаем информацию об открытой позиции
         if(OrderSelect(i, SELECT_BY_POS))
           {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
              {
               hasPosition = true;
              }

           }
        }
     }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   last_candle_time = Time[0];   // Получаем время последней свечи
   prev_day_start_time = iTime(_Symbol, PERIOD_D1, 1);   // Получаем время начала предыдущего торгового дня
   prev_day_of_week = TimeDayOfWeek(prev_day_start_time);

   while(prev_day_of_week == 0 || prev_day_of_week == 6)
     {
      prev_day_start_time -= PeriodSeconds(PERIOD_D1);   // Если предыдущий день выходной, уменьшаем дату на один день
      prev_day_of_week = TimeDayOfWeek(prev_day_start_time);
     }

   if(!hasPosition)
     {
      if(TimeHour(currentTime) == 00 && TimeMinute(currentTime) == 15)
        {

         last_candle_index = iBarShift(_Symbol, PERIOD_D1, last_candle_time); // Получаем индекс последней свечи на дневном графике


         prev_day_index = iBarShift(_Symbol, PERIOD_D1, prev_day_start_time);  // Получаем индекс свечи предыдущего дня на дневном графике


         prevDayHight = iHigh(_Symbol, PERIOD_D1, prev_day_index); // Получаем максимум и минимум предыдущего дня
         prevDayLow = iLow(_Symbol, PERIOD_D1, prev_day_index);


         buyStopOrderSentFirstBuy = false;
         sellStopOrderSentFirstSell = false;
        }
     }
   prevDayClose = iClose(_Symbol, PERIOD_D1, 1);
   prevDayOpen = iOpen(_Symbol, PERIOD_D1, 1);











//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(TimeHour(currentTime) == 23 && TimeMinute(currentTime) == 50)
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
                  if(closedA)
                    {Print("Trade closed successfully!");}
                  else
                    {Print("Failed to close trade! Error code: ", GetLastError());}
                 }
               if(OrderType() == OP_SELL)
                 {
                  bool closedB = OrderClose(OrderTicket(), OrderLots(), current_priceA, 10, clrRed);
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






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(TimeHour(currentTime) == 00 && TimeMinute(currentTime) == 30 && !hasPosition && MathAbs(ema5 - ema90) < 1000 * Point)
     {
      //+-------------------------Запуск торгов-----------------------------------------+
      if(prevDayClose > prevDayOpen && !buyStopOrderSentFirstBuy && ema5 > ema90)
        {
         bool result0 = OrderSend(Symbol(), OP_BUY, lotsize, Ask, 3, 0, 0, "my comment", 2222); // Отправляем ордер на торговый сервер
         buyStopOrderSentFirstBuy = true;
        }
      if(prevDayClose < prevDayOpen && !sellStopOrderSentFirstSell && ema5 < ema90 && MathAbs(ema90 - ema5) < 1000 * Point)
        {
         bool result00 = OrderSend(Symbol(), OP_SELL, lotsize, Bid, 3, 0, 0, "my comment", 3333); // Отправляем ордер на торговый сервер
         sellStopOrderSentFirstSell = true;
        }
     }







//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   Comment("hasPosition: ", hasPosition, " ordersTotal: ", ordersTotal, " prevDayHight: ", prevDayHight, " prevDayLow: ", prevDayLow);






  }
//+------------------------------------------------------------------+
