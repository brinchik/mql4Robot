//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
datetime last_candle_time;
datetime prev_day_start_time;

int last_candle_index;
int prev_day_index;
int prev_day_of_week;

double prevDayHight;
double prevDayLow;

int text_handle; // Объявляем переменную для хранения идентификатора текстового объекта


double EMA5;
double EMA90;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {


//+------------------------------------------------------------------+
//? Получаем макс. и мин. предыдущего дня
//+------------------------------------------------------------------+
   prev_day_start_time = iTime(_Symbol, PERIOD_D1, 1);
   prev_day_of_week = TimeDayOfWeek(prev_day_start_time);
   while(prev_day_of_week == 0 || prev_day_of_week == 6)
     {
      // Если предыдущий день выходной, уменьшаем дату на один день
      prev_day_start_time -= PeriodSeconds(PERIOD_D1);
      prev_day_of_week = TimeDayOfWeek(prev_day_start_time);
     }
   prev_day_index = iBarShift(_Symbol, PERIOD_D1, prev_day_start_time);
// Получаем максимум и минимум предыдущего дня
   prevDayHight = iHigh(_Symbol, PERIOD_D1, prev_day_index);
   prevDayLow = iLow(_Symbol, PERIOD_D1, prev_day_index);

//+------------------------------------------------------------------+
//? Рисуем макс. и мин. предыдущего дня
//+------------------------------------------------------------------+
   datetime startTime = iTime(_Symbol, PERIOD_D1, 1); // Время начала предыдущего дня

   datetime endOfDay = TimeCurrent(); // Текущее время
   int year = TimeYear(endOfDay); // Год
   int month = TimeMonth(endOfDay); // Месяц
   int day = TimeDay(endOfDay); // День
   int endHour = 23; // Часы
   int endMinute = 59; // Минуты

   endOfDay = StrToTime(year + "." + month + "." + day + " " + endHour + ":" + endMinute); // Установка времени на 23:59

// Рисование линии максимума предыдущего дня
   ObjectCreate(0, "MaxLine", OBJ_TREND, 0, startTime, prevDayHight, endOfDay, prevDayHight);
   ObjectSet("MaxLine", OBJPROP_COLOR, clrGray); // Изменение цвета на серый
   ObjectSet("MaxLine", OBJPROP_WIDTH, 2); // Изменение толщины на 2
   ObjectSet("MaxLine", OBJPROP_RAY, false);

// Рисование линии минимума предыдущего дня
   ObjectCreate(0, "MinLine", OBJ_TREND, 0, startTime, prevDayLow, endOfDay, prevDayLow);
   ObjectSet("MinLine", OBJPROP_COLOR, clrGray); // Изменение цвета на серый
   ObjectSet("MinLine", OBJPROP_WIDTH, 2); // Изменение толщины на 2
   ObjectSet("MinLine", OBJPROP_RAY, false); // Удаление галочки "Луч"






//+------------------------------------------------------------------+
//? Считаем прибыль или убыток
//+------------------------------------------------------------------+
   double totalPipsBuy = 0;
   double totalPipsSell = 0;
   string currentSymbol = Symbol(); // Получаем имя текущего символа графика

   for(int e = OrdersTotal() - 1; e >= 0; e--)
     {
      if(OrderSelect(e, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == currentSymbol)  // Проверяем, соответствует ли символ ордера текущему символу графика
           {
            if(OrderType() == OP_BUY)
              {
               double profit = OrderProfit();
               double symbolPoint = SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_SIZE);
               double pips = profit / symbolPoint;
               totalPipsBuy += pips / 100000;
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  double profit1 = OrderProfit();
                  double symbolPoint1 = SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_SIZE);
                  double pips1 = profit1 / symbolPoint1;
                  totalPipsSell += pips1 / 100000;
                 }
           }
        }
     }



//+------------------------------------------------------------------+
//? Подсчитываем количество лотов на покупку и на продажу
//+------------------------------------------------------------------+
   int totalPositions = OrdersTotal();

   double totalLotsSell = 0;
   double totalLotsBuy = 0;

   for(int i = 0; i < totalPositions; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == currentSymbol)  // Проверяем, соответствует ли символ ордера текущему символу графика
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
     }



//+------------------------------------------------------------------+
//? Рисуем ема5 и ема90 в отдельном окне
//+------------------------------------------------------------------+
   EMA5 = iMA(_Symbol, PERIOD_H1, 5, 0, MODE_EMA, PRICE_CLOSE, 0); // Рассчитываем EMA5
   EMA90 = iMA(_Symbol, PERIOD_H1, 90, 0, MODE_EMA, PRICE_CLOSE, 0); // Рассчитываем EMA90

   if(EMA5 < EMA90)
     {
      double distance = MathAbs(EMA5 - EMA90); // Расчет расстояния между ema5 и ema90
      double point = Point(); // Значение точности цены
      // Выводим сообщение в правом верхнем углу графика с расстоянием
      string text = "• Distance: " + DoubleToStr(distance/point, 2) + " points";
      text_handle = ObjectCreate("Text_Label", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Text_Label", text, 10, "Arial", Red);
      ObjectSet("Text_Label", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSet("Text_Label", OBJPROP_XDISTANCE, 10);
      ObjectSet("Text_Label", OBJPROP_YDISTANCE, 10);
     }
   else
     {
      double distance2 = MathAbs(EMA5 - EMA90); // Расчет расстояния между ema5 и ema90
      double point2 = Point(); // Значение точности цены
      // Выводим сообщение в правом верхнем углу графика с расстоянием
      string text2 = "• Distance: " + DoubleToStr(distance2/point2, 2) + " points";
      text_handle = ObjectCreate("Text_Label", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Text_Label", text2, 10, "Arial", clrGreen);
      ObjectSet("Text_Label", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSet("Text_Label", OBJPROP_XDISTANCE, 10);
      ObjectSet("Text_Label", OBJPROP_YDISTANCE, 10);
     }





//+------------------------------------------------------------------+
//? Выводим коменты
//+------------------------------------------------------------------+
   Comment("totalPipsBuy: ", totalPipsBuy, " | totalPipsSell: ", totalPipsSell, " \r\ntotalLotsBuy: ", totalLotsBuy, " | totalLotsSell: ", totalLotsSell);

  }






//+------------------------------------------------------------------+
//? Кнопка закрыть позиции
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "BuyButton") // Проверяем, что была нажата кнопка на графике
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
                  bool closedA = OrderClose(OrderTicket(), OrderLots(), current_priceB, 10, clrForestGreen);
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
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   ObjectCreate("BuyButton", OBJ_BUTTON, 0, 0, 0); // Создаем кнопку "Купить"
   ObjectSetString(0, "BuyButton", OBJPROP_TEXT, "Закрыть"); // Устанавливаем текст на кнопке
   ObjectSetInteger(0, "BuyButton", OBJPROP_XDISTANCE, 200); // Устанавливаем отступ кнопки по оси X
   ObjectSetInteger(0, "BuyButton", OBJPROP_YDISTANCE, 20); // Устанавливаем отступ кнопки по оси Y
   return(0);
  }

//+------------------------------------------------------------------+
