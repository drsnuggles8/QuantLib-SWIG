
/*
 Copyright (C) 2000, 2001, 2002 RiskMap srl

 This file is part of QuantLib, a free-software/open-source library
 for financial quantitative analysts and developers - http://quantlib.org/

 QuantLib is free software: you can redistribute it and/or modify it under the
 terms of the QuantLib license.  You should have received a copy of the
 license along with this program; if not, please email ferdinando@ametrano.net
 The license is also available online at http://quantlib.org/html/license.html

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
*/

// $Id$

#ifndef quantlib_swap_i
#define quantlib_swap_i

%include instruments.i
%include termstructures.i
%include cashflows.i

%{
using QuantLib::Instruments::Swap;
using QuantLib::Instruments::SimpleSwap;
typedef Handle<Instrument> SwapHandle;
typedef Handle<Instrument> SimpleSwapHandle;
%}

%rename(Swap) SwapHandle;
class SwapHandle : public Handle<Instrument> {};
%extend SwapHandle {
    SwapHandle(const std::vector<Handle<CashFlow> >& firstLeg,
               const std::vector<Handle<CashFlow> >& secondLeg,
               const RelinkableHandle<TermStructure>& termStructure,
               const std::string& isinCode = "unknown", 
               const std::string& description = "interest rate swap") {
        return new SwapHandle(new Swap(firstLeg, secondLeg, termStructure,
                                       isinCode, description));
    }
}

#if defined(SWIGRUBY)
// too many parameters for a native function.
// we'll have to group some
%inline %{
class FixedSwapLeg {
  public:
    FixedSwapLeg(int fixedFrequency, Rate fixedRate,
                 bool fixedIsAdjusted, const DayCounter& fixedDayCount)
    : fixedFrequency(fixedFrequency), fixedRate(fixedRate),
      fixedIsAdjusted(fixedIsAdjusted), fixedDayCount(fixedDayCount) {}
    int fixedFrequency;
    Rate fixedRate;
    bool fixedIsAdjusted;
    DayCounter fixedDayCount;
};
class FloatingSwapLeg {
  public:
    FloatingSwapLeg(int floatingFrequency, XiborHandle index, 
                    int indexFixingDays, Spread spread)
    : floatingFrequency(floatingFrequency), index(index),
      indexFixingDays(indexFixingDays), spread(spread) {}
    int floatingFrequency;
    XiborHandle index;
    int indexFixingDays;
    Spread spread;
};
%}
#endif


#if defined(SWIGMZSCHEME) || defined(SWIGGUILE)
%rename("fair-rate")        fairRate;
%rename("fair-spread")      fairSpread;
%rename("fixed-leg-BPS")    fixedLegBPS;
%rename("floating-leg-BPS") floatingLegBPS;
#endif

%rename(SimpleSwap) SimpleSwapHandle;
class SimpleSwapHandle : public Handle<Instrument> {};
#if defined(SWIGRUBY)
%extend SimpleSwapHandle {
    SimpleSwapHandle(bool payFixedRate, const Date& startDate, 
                     int n, TimeUnit unit, const Calendar& calendar, 
                     RollingConvention rollingConvention, double nominal,
                     const FixedSwapLeg& fixedLeg,
                     const FloatingSwapLeg& floatingLeg,
                     const RelinkableHandle<TermStructure>& termStructure, 
                     const std::string& isinCode, 
                     const std::string& description) {
        return new SimpleSwapHandle(
            new SimpleSwap(payFixedRate, startDate, n, unit, calendar,
                           rollingConvention, nominal, 
                           fixedLeg.fixedFrequency, fixedLeg.fixedRate, 
                           fixedLeg.fixedIsAdjusted, fixedLeg.fixedDayCount, 
                           floatingLeg.floatingFrequency, floatingLeg.index, 
                           floatingLeg.indexFixingDays, floatingLeg.spread, 
                           termStructure, isinCode, description));
    }
}
#else
%extend SimpleSwapHandle {
    SimpleSwapHandle(bool payFixedRate, const Date& startDate, 
                     int n, TimeUnit unit, const Calendar& calendar, 
                     RollingConvention rollingConvention, double nominal, 
                     int fixedFrequency, Rate fixedRate,
                     bool fixedIsAdjusted, const DayCounter& fixedDayCount,
                     int floatingFrequency, const XiborHandle& index, 
                     int indexFixingDays, Spread spread, 
                     const RelinkableHandle<TermStructure>& termStructure, 
                     const std::string& isinCode = "unknown", 
                     const std::string& description = "interest rate swap") {
        return new SimpleSwapHandle(
            new SimpleSwap(payFixedRate, startDate, n, unit, calendar,
                           rollingConvention, nominal, fixedFrequency, 
                           fixedRate, fixedIsAdjusted, fixedDayCount, 
                           floatingFrequency, index, indexFixingDays, 
                           spread, termStructure, isinCode, description));
    }
}
#endif
%extend SimpleSwapHandle {
    Rate fairRate() {
        return Handle<SimpleSwap>(*self)->fairRate();
    }
    Spread fairSpread() {
        return Handle<SimpleSwap>(*self)->fairSpread();
    }
    double fixedLegBPS() {
        return Handle<SimpleSwap>(*self)->fixedLegBPS();
    }
    double floatingLegBPS() {
        return Handle<SimpleSwap>(*self)->floatingLegBPS();
    }
    Date maturity() {
        return Handle<SimpleSwap>(*self)->maturity();
    }
}


#endif