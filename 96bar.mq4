//+------------------------------------------------------------------+
//|                                                    BuySellStop.mq4|
//|                                  Copyright 2023, Example, Inc.    |
//|                                              https://example.com/ |
//+------------------------------------------------------------------+
double accountBalance;



// ? Инпуты для ввода данных
input int numEmaF = 5;
input int numEmaS = 90;

input int numBarIwant = 96;

input int firstOrderIwant = 2;
input int MathAbs1 = 175;

input int limitordersIwant = 2;
input int priceStepLimOrders = 20;
input int MathAbs2 = 100;
input int sumUpLimOrders = 100;

input double totalPipsIwant = 25;
//+------------------------------------------------------------------+
double slippage = 2;
double lotSize = 0.1;
double lot = 0;
int MagicNumber = 003;
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
bool sellStopOrderSent0 = false;
bool buyStopOrderSent0 = false;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool buy1Green = false;
bool buy1Red = false;
bool buy2Green = false;
bool buy2Red = false;
bool buy3 = false;
bool buy4 = false;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double EMA5;
double EMA90;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int sumUpGreen = 0;
int sumUpRed = 0;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool flag1 = false;
bool flag2 = false;
bool flag3Green = false;
bool flag3Red = false;
bool flag4Green = false;
bool flag4Red = false;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   accountBalance = AccountBalance();
   datetime currentTime = TimeCurrent();


   double prevDayClose2 = iClose(_Symbol, PERIOD_D1, 2);
   double prevDayOpen2 = iOpen(_Symbol, PERIOD_D1, 2);
   double prevDayClose1 = iClose(_Symbol, PERIOD_D1, 1);
   double prevDayOpen1 = iOpen(_Symbol, PERIOD_D1, 1);
   bool flag20 = false;
   if(prevDayClose1 > prevDayClose2 && prevDayClose2 > prevDayOpen2)
     {
      flag20 = true;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int countBarsGreen = 0;
   int countBarsRed = 0;
   bool flagPriceGreen = false;
   bool flagPriceRed = false;
   double maxPriceBarGreen = 0;
   double maxPriceBarRed = 0;
   double firstPriceBarGreen = 0;
   double firstPriceBarRed = 0;
   double prevCloseGreen = iLow(_Symbol, PERIOD_CURRENT, 1);
   double prevCloseRed = iHigh(_Symbol, PERIOD_CURRENT, 1);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool longCondition = (EMA5 > EMA90) && (EMA5 - EMA90 > 0.0001);
   bool shortCondition = (EMA5 < EMA90) && (EMA90 - EMA5 > 0.0001);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   EMA5 = iMA(_Symbol, _Period, numEmaF, 0, MODE_EMA, PRICE_CLOSE, 0);
   EMA90 = iMA(_Symbol, _Period, numEmaS, 0, MODE_EMA, PRICE_CLOSE, 0);

   flag1 = (EMA5 > EMA90 && Bid > EMA90);
   flag2 = (EMA5 < EMA90 && Ask < EMA90);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(flag1)
     {
      flagPriceGreen = true;
      for(int q = 1; q <= 500; q++)
        {
         double ema5_i = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE, q);
         double ema90_i = iMA(_Symbol, _Period, 90, 0, MODE_EMA, PRICE_CLOSE, q);
         if(ema5_i > ema90_i)
           {
            countBarsGreen++;
            if(countBarsGreen == numBarIwant)
              {
               flag3Green = true;
               break;
              }
           }
         else
           {
            countBarsGreen = 0;
            flag3Green = false;

            flag4Green = false;
            sumUpGreen = 0;
            maxPriceBarGreen = 0;
            firstPriceBarGreen = 0;
            buy1Green = false;
            break;
           }
         if(flagPriceGreen)
           {
            double currentPriceGreen = NormalizeDouble(High[q], Digits);
            if(maxPriceBarGreen > currentPriceGreen)
              {
               maxPriceBarGreen = currentPriceGreen;
              }
            if(firstPriceBarGreen == 0)
              {
               firstPriceBarGreen = currentPriceGreen;
              }
           }
        }
      if(flag3Green && flagPriceGreen)
        {
         sumUpGreen = (maxPriceBarGreen - firstPriceBarGreen) / Point;
        }
     }
   else
     {
      flagPriceGreen = false;
     }

    //  -----------------------------------------------------------

    if(flag2)
     {
      flagPriceRed = true;
      for(int p = 1; p <= 500; p++)
        {
         double ema5_s = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE, p);
         double ema90_s = iMA(_Symbol, _Period, 90, 0, MODE_EMA, PRICE_CLOSE, p);
         if(ema5_s < ema90_s)
           {
            countBarsRed++;
            if(countBarsRed == numBarIwant)
              {
               flag3Red = true;
               break;
              }
           }
         else
           {
            countBarsRed = 0;
            flag3Red = false;

            flag4Red = false;
            sumUpRed = 0;
            maxPriceBarRed = 0;
            firstPriceBarRed = 0;
            buy1Red = false;
            break;
           }
         if(flagPriceRed)
           {
            double currentPriceRed = NormalizeDouble(Low[p], Digits);
            if(maxPriceBarRed == 0 || maxPriceBarRed > currentPriceRed)
              {
               maxPriceBarRed = currentPriceRed;
              }
            if(firstPriceBarRed == 0)
              {
               firstPriceBarRed = currentPriceRed;
              }
           }
        }
      if(flag3Red && flagPriceRed)
        {
         sumUpRed = (firstPriceBarRed - maxPriceBarRed) / Point;
        }
     }
   else
     {
      flagPriceRed = false;
     }

//+------------------------------------------------------------------+
//? Считаем прибыль или убыток
//+------------------------------------------------------------------+
   double totalPipsBuy = 0;
   double totalPipsSell = 0;
   for(int e = OrdersTotal() - 1; e >= 0; e--)
     {
      if(OrderSelect(e, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderType() == OP_BUY)
           {
            double profit = OrderProfit();
            double symbolPoint = SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_SIZE);
            double pips = profit / symbolPoint;
            totalPipsBuy += pips / 100000;
           }
        }
     }
for(int e1 = OrdersTotal() - 1; e1 >= 0; e1--)
     {
      if(OrderSelect(e1, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderType() == OP_SELL)
           {
            double profit1 = OrderProfit();
            double symbolPoint1 = SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_SIZE);
            double pips1 = profit1 / symbolPoint1;
            totalPipsSell += pips1 / 100000;
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
//! Начало торговли
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//? Открываем сделку когда ема5 выше 90й в течении 96 баров (8часов на М5)
//+------------------------------------------------------------------+
   int numberOfOrders = firstOrderIwant;


      if(MathAbs(EMA5 - EMA90) > MathAbs1 * Point)
        {
         if(flag1 && flag3Green && !buy1Green && prevCloseGreen > EMA90)
           {
            for(int t = 0; t < numberOfOrders; t++)
              {
               bool result = OrderSend(_Symbol, OP_SELL, lotSize, Bid, 3, 0, 0, "EMA cross", 123, 0, Green);
               if(result)
                 {
                  Print("Buy order ", MagicNumber, " opened successfully!");
                  buy1Green = true;
                  flag4Green = true;
                 }
               else
                 {
                  Print("Failed to open buy order ", MagicNumber, "! Error code: ", GetLastError());
                 }
              }
           }
        }
        
        if(MathAbs(EMA90 - EMA5) > MathAbs1 * Point)
        {
         if(flag2 && flag3Red && !buy1Red && prevCloseRed < EMA90)
           {
            for(int t1 = 0; t1 < numberOfOrders; t1++)
              {
               bool resultRed = OrderSend(_Symbol, OP_BUY, lotSize, Ask, 3, 0, 0, "EMA cross", 123, 0, Green);
               if(resultRed)
                 {
                  Print("Buy order ", MagicNumber, " opened successfully!");
                  buy1Red = true;
                  flag4Red = true;
                 }
               else
                 {
                  Print("Failed to open buy order ", MagicNumber, "! Error code: ", GetLastError());
                 }
              }
           }
        }
     
//+------------------------------------------------------------------+
//? Устанавливаем SellLimit на ближайший максимум
//+------------------------------------------------------------------+
//  int limitorders = totalLotsSell * 10;
   int limitorders = limitordersIwant;
   double priceStepGreen = 20 * Point;
   double priceStepRed = 20 * Point;
   double lt = 0.1;
   double lotSize2 = 0.1;
   if(MathAbs(EMA5 - EMA90) > MathAbs2 * Point)
     {
      if(flag4Green && sumUpGreen >= sumUpLimOrders && !buy2Green)
        {
         for(int y = 0; y < limitorders; y++)
           {
            bool result1 = OrderSend(_Symbol, OP_SELLLIMIT, lotSize2, maxPriceBarGreen, 3, 0, 0, "EMA cross", 123, 0, Green);
            if(result1)
              {
               Print("Buy order ", MagicNumber, " opened successfully!");
               buy2Green = true;
              }
            else
              {
               Print("Failed to open buy order ", MagicNumber, "! Error code: ", GetLastError());
              }
            maxPriceBarGreen += priceStepGreen;
            lotSize2 += lt;
           }
        }
     }
   if(sumUpGreen == 0 && buy2Green)
     {
      buy2Green = false;
     }

    //  ----------------------------------------
    if(MathAbs(EMA90 - EMA5) > MathAbs2 * Point)
     {
      if(flag4Red && sumUpRed >= sumUpLimOrders && !buy2Red)
        {
         for(int y1 = 0; y1 < limitorders; y1++)
           {
            bool resultRed1 = OrderSend(_Symbol, OP_BUYLIMIT, lotSize2, maxPriceBarRed, 3, 0, 0, "EMA cross", 123, 0, Green);
            if(resultRed1)
              {
               Print("Buy order ", MagicNumber, " opened successfully!");
               buy2Red = true;
              }
            else
              {
               Print("Failed to open buy order ", MagicNumber, "! Error code: ", GetLastError());
              }
            maxPriceBarRed += priceStepRed;
            lotSize2 += lt;
           }
        }
     }
   if(sumUpRed == 0 && buy2Red)
     {
      buy2Red = false;
     }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double high = iHigh(Symbol(), PERIOD_CURRENT, 0);
   double low = iLow(Symbol(), PERIOD_CURRENT, 0);

//  if((high - low) > 300 * Point && !buy3)
//    {
//     OrderSend(_Symbol, OP_BUY, totalLotsSell, Ask, 3, 25 * Point, 0, "EMA cross", 01, 0, Green);
//     buy3 = true;
//    }
//  if((high - low) > 300 * Point && !buy4 && buy3)
//    {
//     OrderSend(_Symbol, OP_BUY, totalLotsSell - totalLotsBuy, Ask, 3, 0, 0, "EMA cross", 01, 0, Green);
//     buy4 = true;
//    }
// if (totalPips <= -1000 && !buy4) {
//     OrderSend(_Symbol, OP_BUY, totalLotsSell * 4, Ask, 3, 0, 0, "EMA cross", 123, 0, Green);
//    buy4 = true;
// }


//  if(accountBalance >= 11000)
//    {
//     lot = +0.1;
//    }
//  if(accountBalance >= 12000)
//    {
//     lot = +0.2;
//    }
//  if(accountBalance >= 13000)
//    {
//     lot = +0.3;
//    }
//  if(accountBalance >= 14000)
//    {
//     lot = +0.4;
//    }
//  if(accountBalance >= 15000)
//    {
//     lot = +0.5;
//    }
//  if(accountBalance >= 16000)
//    {
//     lot = +0.6;
//    }
//  if(accountBalance >= 17000)
//    {
//     lot = +0.7;
//    }
//  if(accountBalance >= 18000)
//    {
//     lot = +0.8;
//    }
//  if(accountBalance >= 19000)
//    {
//     lot = +0.9;
//    }
//  if(accountBalance >= 20000)
//    {
//     lot = +1;
//    }
//+------------------------------------------------------------------+
//? Закрываем сделки и ордера при достижении прибыли в пунктах
//+------------------------------------------------------------------+
//  || totalPips <= -1000
   if(totalPipsSell >= totalPipsIwant)
     {
      double current_priceB = MarketInfo(Symbol(), MODE_BID);
      double current_priceA = MarketInfo(Symbol(), MODE_ASK);
      for(int ci = OrdersTotal() - 1; ci >= 0; ci--)
        {
         if(OrderSelect(ci, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() == _Symbol) // Убедитесь, что это сделка для текущего символа
              {
               if(OrderType() == OP_SELL)
                 {
                  bool closedSell = OrderClose(OrderTicket(), OrderLots(), current_priceA, 10, clrRed);
                  flag4Green = false;
           
                  lotSize2 = 0.1;
                  if(closedSell)
                    {Print("Trade Sell closed OK!");}
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
            if(OrderType() == OP_SELLLIMIT)
              {
               bool closedAllOrder = OrderDelete(OrderTicket());
               if(closedAllOrder)
                 {Print("Order closed OK!");}
               else
                 {Print("Failed to close Order! Error code: ", GetLastError());}
              }
           }
        }
     }
  if(totalPipsBuy >= totalPipsIwant)
     {
      double current_priceB1 = MarketInfo(Symbol(), MODE_BID);
      double current_priceA1 = MarketInfo(Symbol(), MODE_ASK);
      for(int ci1 = OrdersTotal() - 1; ci1 >= 0; ci1--)
        {
         if(OrderSelect(ci1, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() == _Symbol) // Убедитесь, что это сделка для текущего символа
              {
               if(OrderType() == OP_BUY)
                 {
                  bool closedBuy1 = OrderClose(OrderTicket(), OrderLots(), current_priceB1, 10, clrRed);
             
                  flag4Red = false;
                  lotSize2 = 0.1;
                  if(closedBuy1)
                    {Print("Trade Buy closed OK!");}
                  else
                    {Print("Failed to close trade! Error code: ", GetLastError());}
                 }


              }
           }
        }

      for(int cl22 = OrdersTotal() - 1; cl22 >= 0; cl22--)
        {
         if(OrderSelect(cl22, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderType() == OP_BUYLIMIT)
              {
               bool closedAllOrder1 = OrderDelete(OrderTicket());
               if(closedAllOrder1)
                 {Print("Order closed OK!");}
               else
                 {Print("Failed to close Order! Error code: ", GetLastError());}
              }
           }
        }
     }


//  if(TimeHour(currentTime) == 23 && TimeMinute(currentTime) == 59)
//    {
//     double current_priceB1 = MarketInfo(Symbol(), MODE_BID);
//     double current_priceA1 = MarketInfo(Symbol(), MODE_ASK);
//     for(int ci1 = OrdersTotal() - 1; ci1 >= 0; ci1--)
//       {
//        if(OrderSelect(ci1, SELECT_BY_POS, MODE_TRADES))
//          {
//           if(OrderSymbol() == _Symbol) // Убедитесь, что это сделка для текущего символа
//             {
//              if(OrderType() == OP_BUY)
//                {
//                 bool closedBuy1 = OrderClose(OrderTicket(), OrderLots(), current_priceB1, 10, clrRed);
//                 flag4 = false;
//                 lotSize2 = 0.1;
//                 if(closedBuy1)
//                   {Print("Trade Buy closed OK!");}
//                 else
//                   {Print("Failed to close trade! Error code: ", GetLastError());}
//                }
//              if(OrderType() == OP_SELL)
//                {
//                 bool closedSell1 = OrderClose(OrderTicket(), OrderLots(), current_priceA1, 10, clrRed);
//                 flag4 = false;
//                 lotSize2 = 0.1;
//                 if(closedSell1)
//                   {Print("Trade Sell closed OK!");}
//                 else
//                   {Print("Failed to close trade! Error code: ", GetLastError());}
//                }

//             }
//          }
//       }

//     for(int cl22 = OrdersTotal() - 1; cl22 >= 0; cl22--)
//       {
//        if(OrderSelect(cl22, SELECT_BY_POS, MODE_TRADES))
//          {
//           if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
//             {
//              bool closedAllOrder1 = OrderDelete(OrderTicket());
//              if(closedAllOrder1)
//                {Print("Order closed OK!");}
//              else
//                {Print("Failed to close Order! Error code: ", GetLastError());}
//             }
//          }
//       }
//    }




   Comment("flag1: ", flag1, " | flag2: ", flag2, " \r\nflag3Green: ", flag3Green, " | countBarsGreen: ", countBarsGreen, " | maxPriceBarGreen: ", maxPriceBarGreen, " | sumUpGreen: ", sumUpGreen, " | flag4Green: ", flag4Green, " | buy1Green: ", buy1Green, " \r\nflag3Red: ", flag3Red, " | countBarsRed: ", countBarsRed, " | maxPriceBarRed: ", maxPriceBarRed, " | sumUpRed: ", sumUpRed, " | flag4Red: ", flag4Red, " | buy1Red: ", buy1Red, " \r\naccountBalance: ", accountBalance, " | totalLotsSell: ", totalLotsSell, " | totalLotsBuy: ", totalLotsBuy, " | totalPipsBuy: ", totalPipsBuy);

  }
//+------------------------------------------------------------------+
