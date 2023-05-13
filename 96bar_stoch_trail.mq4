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


int stochPeriod = 14; // Период стохастического осциллятора
int stochK = 5; // %K стохастического осциллятора
int stochD = 3; // %D стохастического осциллятора
int stochSlow = 3; // Замедляющая линия стохастического осциллятора


bool flag30 = false; // Флаг для обозначения превышения стохастиком уровня 80
double stochMain, stochSignal,stochMain1, stochSignal1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double trailingStart = 25; // Расстояние в пунктах для активации трейлинг-стопа
double trailingDistance = 30; // Расстояние в пунктах для движения трейлинг-стопа
double currentStopLoss = 0; // Текущий уровень стоп-лосса
void OnTick()
  {

stochMain = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,0);
stochSignal = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);

stochMain1 = iStochastic(NULL,PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,0);
stochSignal1 = iStochastic(NULL,PERIOD_M15,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);
// Получаем значения стохастического осциллятора

        if (stochMain && stochMain1 > 80 && stochSignal && stochSignal1 > 80)
        {
            flag30 = true;
           
        }
        else
        {
            flag30 = false;
             
        }
 


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

// bool g1 = false;

// if (totalPips >= 25 && !g1)
// {
//     double newStopLoss = NormalizeDouble(Bid + 30 * Point, Digits);
//     for (int u = OrdersTotal() - 1; u >= 0; u--)
//     {
//         if (OrderSelect(u, SELECT_BY_POS, MODE_TRADES))
//         {
//             if (OrderType() == OP_BUY || OrderType() == OP_SELL)
//             {
//                 bool result2 = OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, CLR_NONE);
//                  g1 = true;
//                 if (result2)
//                 {
                 
//                     Print("Stop loss modified for order ", OrderTicket());
//                 }
//                 else
//                 {
//                     Print("Failed to modify stop loss for order ", OrderTicket(), "! Error code: ", GetLastError());
//                 }
//             }
//         }
//     }
// }








    int totalOrders = OrdersTotal();
    
    for (int i2 = totalOrders - 1; i2 >= 0; i2--)
    {
        if (OrderSelect(i2, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_SELL)
            {
                double orderOpenPrice = OrderOpenPrice();
                double currentBid = Bid;
                
                // Активация трейлинг-стопа
                if (currentBid <= orderOpenPrice - trailingStart * Point && currentStopLoss == 0)
                {
                    currentStopLoss = orderOpenPrice - trailingDistance * Point;
                    bool result4 = OrderModify(OrderTicket(), OrderOpenPrice(), currentStopLoss, OrderTakeProfit(), 0, CLR_NONE);
                    
                    if (result4)
                    {
                        Print("Trailing stop activated for order ", OrderTicket());
                    }
                    else
                    {
                        Print("Failed to activate trailing stop for order ", OrderTicket(), "! Error code: ", GetLastError());
                    }
                }
                
                // Движение трейлинг-стопа вниз
                if (currentStopLoss > 0 && currentBid <= currentStopLoss)
                {
                    double newStopLoss = currentBid + 30 * Point;
                    if (newStopLoss < currentStopLoss) // Проверяем, чтобы новый стоп-лосс был ниже текущего
                    {
                        bool result5 = OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, CLR_NONE);
                        
                        if (result5)
                        {
                            // currentStopLoss = newStopLoss;
                            Print("Trailing stop moved down for order ", OrderTicket());
                        }
                        else
                        {
                            Print("Failed to move trailing stop for order ", OrderTicket(), "! Error code: ", GetLastError());
                        }
                    }
                }
            }
        }
    }









//+------------------------------------------------------------------+
//! Начало торговли
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//? Открываем сделку когда ема5 выше 90й в течении 96 баров (8часов на М5)
//+------------------------------------------------------------------+
   int numberOfOrders = 10;
   if(flag1 && flag3 && !buy1 && prevClose > EMA90)
     {
      for(int t = 0; t < numberOfOrders; t++)
        {
         bool result = OrderSend(_Symbol, OP_SELL, lotSize, Bid, 3, 0, 0, "EMA cross", 123, 0, Green);
         if(result)
           {
            Print("Buy order ", MagicNumber, " opened successfully!");
            buy1 = true;
            flag4 = true;
           }
         else
           {
            Print("Failed to open buy order ", MagicNumber, "! Error code: ", GetLastError());
           }
        }
     }
//+------------------------------------------------------------------+
//? Устанавливаем SellLimit на ближайший максимум
//+------------------------------------------------------------------+
   int limitorders = 10;
   double priceStep = 20 * Point;
   if(flag4 && sumUp >= 100 && !buy2)
     {
      for(int y = 0; y < limitorders; y++)
        {
         bool result1 = OrderSend(_Symbol, OP_SELLLIMIT, lotSize, maxPriceBar, 3, 0, 0, "EMA cross", 123, 0, Green);
         if(result1)
           {
            Print("Buy order ", MagicNumber, " opened successfully!");
            buy2 = true;
           }
         else
           {
            Print("Failed to open buy order ", MagicNumber, "! Error code: ", GetLastError());
           }
         maxPriceBar += priceStep;
        }
     }
   if(sumUp == 0 && buy2)
     {
      buy2 = false;
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






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  //  if(totalPips >= 25)
  //    {
  //     double current_priceB = MarketInfo(Symbol(), MODE_BID);
  //     double current_priceA = MarketInfo(Symbol(), MODE_ASK);
  //     for(int ci = OrdersTotal() - 1; ci >= 0; ci--)
  //       {
  //        if(OrderSelect(ci, SELECT_BY_POS, MODE_TRADES))
  //          {
  //           if(OrderSymbol() == _Symbol) // Убедитесь, что это сделка для текущего символа
  //             {
  //              if(OrderType() == OP_BUY)
  //                {
  //                 bool closedBuy = OrderClose(OrderTicket(), OrderLots(), current_priceB, 10, clrRed);
  //                 flag4 = false;
  //                 if(closedBuy)
  //                   {Print("Trade Buy closed OK!");}
  //                 else
  //                   {Print("Failed to close trade! Error code: ", GetLastError());}
  //                }
  //              if(OrderType() == OP_SELL)
  //                {
  //                 bool closedSell = OrderClose(OrderTicket(), OrderLots(), current_priceA, 10, clrRed);
  //                 flag4 = false;
  //                 if(closedSell)
  //                   {Print("Trade Sell closed OK!");}
  //                 else
  //                   {Print("Failed to close trade! Error code: ", GetLastError());}
  //                }

  //             }
  //          }
  //       }

  //     for(int cl2 = OrdersTotal() - 1; cl2 >= 0; cl2--)
  //       {
  //        if(OrderSelect(cl2, SELECT_BY_POS, MODE_TRADES))
  //          {
  //           if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
  //             {
  //              bool closedAllOrder = OrderDelete(OrderTicket());
  //              if(closedAllOrder)
  //                {Print("Order closed OK!");}
  //              else
  //                {Print("Failed to close Order! Error code: ", GetLastError());}
  //             }
  //          }
  //       }
  //    }


   Comment("flag1: ", flag1, " flag2: ", flag2, " flag3: ", flag3, " countBars: ", countBars, " maxPriceBar: ", maxPriceBar, " sumUp: ", sumUp, " totalPips: ", totalPips, " flag4: ", flag4, " buy1: ", buy1, " totalLotsSell: ", totalLotsSell, " totalLotsBuy: ", totalLotsBuy, " stochMain: ", stochMain);

  }
//+------------------------------------------------------------------+
