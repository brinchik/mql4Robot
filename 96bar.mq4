//+------------------------------------------------------------------+
//|                                                    BuySellStop.mq4|
//|                                  Copyright 2023, Example, Inc.    |
//|                                              https://example.com/ |
//+------------------------------------------------------------------+
input double slippage = 2;
input double lotsize = 0.1;
int MagicNumber = 003;


bool sellStopOrderSent0 = false;
bool buyStopOrderSent0 = false;

double EMA5;
double EMA90;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
// устанавливаем параметры скользящих средних
// int fastEMA = 5;
// int slowEMA = 90;
// int shift = 0;
// int applied_price = PRICE_CLOSE;
// int mode = MODE_EMA;
// int ema1 = iMA(_Symbol, _Period, fastEMA, shift, applied_price, mode, PRICE_CLOSE);
// int ema2 = iMA(_Symbol, _Period, slowEMA, shift, applied_price, mode, PRICE_CLOSE);




   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int countBars = 0;
bool flag3 = false;
bool flagPrice = false;
double maxPriceBar = 0;
double firstPriceBar = 0;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   bool longCondition = (EMA5 > EMA90) && (EMA5 - EMA90 > 0.0008);
   bool shortCondition = (EMA5 < EMA90) && (EMA90 - EMA5 > 0.0008);

   bool flag1 = (EMA5 > EMA90) && (EMA5 - EMA90 > 0.0008);
   bool flag2 = (EMA5 < EMA90) && (EMA90 - EMA5 > 0.0008);

// получаем текущие значения EMA5 и EMA90
   EMA5 = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
   EMA90 = iMA(_Symbol, _Period, 90, 0, MODE_EMA, PRICE_CLOSE, 0);






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  if (EMA5 > EMA90 && !flag3)
    {
        countBars = 0;
        flag3 = false;
        flagPrice = true;
        maxPriceBar = 0;
        firstPriceBar = 0;

        for (int q = 1; q <= 500; q++)
        {
            double ema5_i = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, q);
            double ema90_i = iMA(NULL, 0, 90, 0, MODE_EMA, PRICE_CLOSE, q);

            if (ema5_i > ema90_i)
            {
                countBars++;
                if (countBars == 96)
                {
                    flag3 = true;
                    break;
                }
            }
            else
            {
                countBars = 0;
                flag3 = false;
                flagPrice = false;
                break;
            }

            if (flagPrice)
            {
                double currentPrice = Close[q];
                if (maxPriceBar < currentPrice)
                {
                    maxPriceBar = currentPrice;
                }
                if (firstPriceBar == 0)
                {
                    firstPriceBar = currentPrice;
                }
            }
        }
    }
    else if (EMA5 < EMA90)
    {
        countBars = 0;
        flag3 = false;
        flagPrice = false;
        maxPriceBar = 0;
        firstPriceBar = 0;
    }

    if (flag3 && flagPrice)
    {
        double sumUp = (maxPriceBar - firstPriceBar) / Point;
        Print("Max price bar: ", maxPriceBar, " First price bar: ", firstPriceBar, " Sum up: ", sumUp);
    }










// проверяем условие на пересечение EMA5 и EMA90
   if(longCondition)
     {
      // покупаем, если EMA5 пересекла EMA90 сверху вниз
      if(OrdersTotal() == 0 && !buyStopOrderSent0)
        {
         OrderSend(_Symbol, OP_SELL, 0.1, Bid, 3, 0, 0, "EMA cross", 123, 0, Green);
         buyStopOrderSent0 = true;
         sellStopOrderSent0 = false;
        }
     }
   else
      if(shortCondition && !sellStopOrderSent0)
        {
         // продаем, если EMA5 пересекла EMA90 снизу вверх
         if(OrdersTotal() == 0)
           {
            OrderSend(_Symbol, OP_BUY, 0.1, Ask, 3, 0, 0, "EMA cross", 1234, 0, Red);
            sellStopOrderSent0 = true;
            buyStopOrderSent0 = false;
           }
        }

// закрываем позицию, если EMA5 пересекла EMA90 в обратном направлении


// закрыть открытые ордера
   if(OrdersTotal() > 0)
     {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() == _Symbol)
           {
            if((OrderType() == OP_SELL && EMA5 < EMA90) || (OrderType() == OP_BUY && EMA5 > EMA90))
              {
               OrderClose(OrderTicket(), OrderLots(), Ask, slippage, clrRed);
              }
           }
        }
     }
   if(OrdersTotal() > 0)
     {
      for(int ii = OrdersTotal() - 1; ii >= 0; ii--)
        {
         OrderSelect(ii, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() == _Symbol)
           {
            if((OrderType() == OP_SELL && EMA5 < EMA90) || (OrderType() == OP_BUY && EMA5 > EMA90))
              {
               OrderClose(OrderTicket(), OrderLots(), Bid, slippage, clrRed);
              }
           }
        }
     }

   Comment("flag1: ", flag1, " flag2: ", flag2, " flag3: ", flag3, " countBars: ", countBars, " maxPriceBar: ", maxPriceBar, " sumUp: ", sumUp);





  }
//+------------------------------------------------------------------+
