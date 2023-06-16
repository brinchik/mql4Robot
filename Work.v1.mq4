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

//+------------------------------------------------------------------+
//? Очищаем предыдущие линии
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {





//+------------------------------------------------------------------+
//? Получаем максимумы и минимумы предыдущих пяти дней
//+------------------------------------------------------------------+

   datetime startTime;
   datetime endOfDay;
   datetime nextDayStart;
   int labelOffset = 20; // Отступ меток от вертикальных линий
int verticalOffset = 30; //
string allPointLabels = ""; // Строка для хранения всех меток
   for(int i2 = 1; i2 <= 5; i2++)
     {
      prev_day_start_time = iTime(_Symbol, PERIOD_D1, i2);
      prev_day_of_week = TimeDayOfWeek(prev_day_start_time);

      while(prev_day_of_week == 0 || prev_day_of_week == 6)
        {
         // Если предыдущий день выходной, уменьшаем дату на один день
         prev_day_start_time -= PeriodSeconds(PERIOD_D1);
         prev_day_of_week = TimeDayOfWeek(prev_day_start_time);
        }

      prev_day_index = iBarShift(_Symbol, PERIOD_D1, prev_day_start_time);

      // Получаем максимум и минимум предыдущего дня
      double prevDayHigh = iHigh(_Symbol, PERIOD_D1, prev_day_index);
      prevDayLow = iLow(_Symbol, PERIOD_D1, prev_day_index);

      // Вычисляем время начала и конца дня
      startTime = iTime(_Symbol, PERIOD_D1, i2);
      nextDayStart = iTime(_Symbol, PERIOD_D1, i2 - 1);
      int year = TimeYear(nextDayStart);
      int month = TimeMonth(nextDayStart);
      int day = TimeDay(nextDayStart);
      int endHour = 23;
      int endMinute = 59;
      endOfDay = StrToTime(year + "." + month + "." + day + " " + endHour + ":" + endMinute);

      // Рисуем линию максимума предыдущего дня
      ObjectCreate(0, "MaxLine" + IntegerToString(i2), OBJ_TREND, 0, startTime, prevDayHigh, endOfDay, prevDayHigh);
      ObjectSet("MaxLine" + IntegerToString(i2), OBJPROP_COLOR, clrLime);
      ObjectSet("MaxLine" + IntegerToString(i2), OBJPROP_WIDTH, 2);
      ObjectSet("MaxLine" + IntegerToString(i2), OBJPROP_RAY, false);

      // Рисуем линию минимума предыдущего дня
      ObjectCreate(0, "MinLine" + IntegerToString(i2), OBJ_TREND, 0, startTime, prevDayLow, endOfDay, prevDayLow);
      ObjectSet("MinLine" + IntegerToString(i2), OBJPROP_COLOR, clrFireBrick);
      ObjectSet("MinLine" + IntegerToString(i2), OBJPROP_WIDTH, 2);
      ObjectSet("MinLine" + IntegerToString(i2), OBJPROP_RAY, false);

      // Рисуем вертикальную линию от минимума до максимума
      double verticalLineX = startTime + (endOfDay - startTime) / 2;
      double verticalLineYStart = prevDayLow;
      double verticalLineYEnd = prevDayHigh;
      ObjectCreate(0, "VerticalLine" + IntegerToString(i2), OBJ_VLINE, 0, verticalLineX, verticalLineYStart, verticalLineX, verticalLineYEnd);
      ObjectSet("VerticalLine" + IntegerToString(i2), OBJPROP_COLOR, clrDimGray);
      ObjectSet("VerticalLine" + IntegerToString(i2), OBJPROP_WIDTH, 1);

  // Отображаем количество пунктов от минимума до максимума
    double pointDifference = prevDayHigh - prevDayLow;
    string pointLabel = "Points: " + DoubleToString(pointDifference / Point, 2);
    int labelX = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - labelOffset;
    int labelY = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - labelOffset - (labelOffset + verticalOffset) * i2; // Уменьшаем вертикальную координату метки
    // ObjectCreate(0, "PointLabel" + IntegerToString(i2), OBJ_LABEL, 0, labelX, labelY);
    ObjectSet("PointLabel" + IntegerToString(i2), OBJPROP_COLOR, clrGray);
    ObjectSet("PointLabel" + IntegerToString(i2), OBJPROP_BACK, true);
    // ObjectSetText("PointLabel" + IntegerToString(i2), pointLabel, 9, "Arial", clrYellow);
    ObjectSet("PointLabel" + IntegerToString(i2), OBJPROP_ANCHOR, ANCHOR_RIGHT);

    allPointLabels += pointLabel + "\n"; // Добавляем метку в строку всех меток
}







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


 double high = iHigh(Symbol(), PERIOD_D1, 0);
 double low = iLow(Symbol(), PERIOD_D1, 0);
double mm = MathAbs(high - low);
string mm2 = DoubleToStr(mm / Point, 2);

//+------------------------------------------------------------------+
//? Выводим коменты
//+------------------------------------------------------------------+
   Comment("\r\n\r\n\r\ntotalPipsBuy: ", totalPipsBuy, " | totalPipsSell: ", totalPipsSell, " \r\ntotalLotsBuy: ", totalLotsBuy, " | totalLotsSell: ", totalLotsSell," \r\n\r\npointDifferenceNow: ", mm2, " \r\n\r\npointDifference: ", "\r\n",allPointLabels);

  }






//+------------------------------------------------------------------+
//? Кнопка закрыть позиции
//+------------------------------------------------------------------+
// void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
//   {
//    if(id == CHARTEVENT_OBJECT_CLICK && sparam == "BuyButton") // Проверяем, что была нажата кнопка на графике
//      {
//       double current_priceB = MarketInfo(Symbol(), MODE_BID);
//       double current_priceA = MarketInfo(Symbol(), MODE_ASK);
//       for(int ci = OrdersTotal() - 1; ci >= 0; ci--)
//         {
//          if(OrderSelect(ci, SELECT_BY_POS, MODE_TRADES))
//            {
//             if(OrderSymbol() == _Symbol) // Убедитесь, что это сделка для текущего символа
//               {
//                if(OrderType() == OP_BUY)
//                  {
//                   bool closedA = OrderClose(OrderTicket(), OrderLots(), current_priceB, 10, clrForestGreen);
//                   if(closedA)
//                     {Print("Trade closed successfully!");}
//                   else
//                     {Print("Failed to close trade! Error code: ", GetLastError());}
//                  }
//                if(OrderType() == OP_SELL)
//                  {
//                   bool closedB = OrderClose(OrderTicket(), OrderLots(), current_priceA, 10, clrRed);
//                   if(closedB)
//                     {Print("Trade closed successfully!");}
//                   else
//                     {Print("Failed to close trade! Error code: ", GetLastError());}
//                  }

//               }
//            }
//         }
//      }
//   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "DelButton") // Проверяем, что была нажата кнопка на графике
     {
      for(int i3 = ObjectsTotal() - 1; i3 >= 0; i3--)
        {
         string objectName = ObjectName(i3);
         if(StringFind(objectName, "MaxLine") != -1 || StringFind(objectName, "MinLine") != -1 || StringFind(objectName, "VerticalLine") != -1)
           {
            ObjectDelete(0, objectName);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
//  ObjectCreate("BuyButton", OBJ_BUTTON, 0, 0, 0); // Создаем кнопку "Купить"
//  ObjectSetString(0, "BuyButton", OBJPROP_TEXT, "Закрыть"); // Устанавливаем текст на кнопке
//  ObjectSetInteger(0, "BuyButton", OBJPROP_XDISTANCE, 200); // Устанавливаем отступ кнопки по оси X
//  ObjectSetInteger(0, "BuyButton", OBJPROP_YDISTANCE, 20); // Устанавливаем отступ кнопки по оси Y

   ObjectCreate("DelButton", OBJ_BUTTON, 0, 0, 0); // Создаем кнопку "Купить"
   ObjectSetString(0, "DelButton", OBJPROP_TEXT, "Del"); // Устанавливаем текст на кнопке
   ObjectSetInteger(0, "DelButton", OBJPROP_XDISTANCE, 200); // Устанавливаем отступ кнопки по оси X
   ObjectSetInteger(0, "DelButton", OBJPROP_YDISTANCE, 20); // Устанавливаем отступ кнопки по оси Y
   return(0);
  }

//+------------------------------------------------------------------+
