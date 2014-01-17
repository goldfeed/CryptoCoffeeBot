###
Wikimoku v0.2 - Thanasis / BTCorbust / et al 

Tipping Addresses:
https://github.com/wildownes/CryptoCoffeeBot/blob/master/CREDITS.txt

Ichimoku + Heikin-Ashi + Parabolic SAR +
AROON + MACD + RSI + Auto Market Config 

****Module Credits**** (PLEASE KEEP UPDATED)
OpenSettings module v0.1 by wild0wnes
    BTC 1FCmfke28oSjJA7VCMLFnoCxqSQaGRaW7b

SimplePlot module v1 by wild0wnes
    BTC 1FCmfke28oSjJA7VCMLFnoCxqSQaGRaW7b

Stats & Orders module v0.4.6 by sportpilot
    BTC 1561k5XqWFJSHP8apmvGt15ecWjw9ZLKGi
###



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OpenSettings - v0.1 by wild0wnes
# BTC - 1FCmfke28oSjJA7VCMLFnoCxqSQaGRaW7b
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class OpenSettings
  @module_disabler: (context, data)->
    context.OS_module1 = false #SimplePlot True/False
    context.OS_module2 = true #Stats True/False

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SimplePlot module v1 by wild0wnes
# BTC - 1FCmfke28oSjJA7VCMLFnoCxqSQaGRaW7b
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SimplePlot
  @handle: (context, data)->
    instrument = data.instruments[0]
    Close = instrument.close[instrument.close.length - 1]
    High = instrument.high[instrument.high.length - 1]
    Low = instrument.low[instrument.low.length - 1]
    plot
      Close: Close
      High: High
      Low: Low

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stats & Orders module v0.4.6 by sportpilot
# BTC - 1561k5XqWFJSHP8apmvGt15ecWjw9ZLKGi
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Description: This module provides Statistics reporting
#     and the ability to use Limit Orders, change the
#     Trade Timeout, set USD limit or to set Reserves  
#     for USD &/or BTC.
#
class Stats
  @handle: (context, data)->
    context.cur_ins = data[context.pair]
    context.cur_data = data
    context.cur_portfolio = portfolio
    for key, value of _.toArray(context.cur_portfolio)[0]
      context.currs.push key
    if context.value_initial == 0
      Stats.initial(context)


  @initial: (context) ->
    positions = _.toArray(context.cur_portfolio.positions)
    context.trader_curr1 = positions[0].amount
    context.trader_curr2 = positions[1].amount

    if context.trader_curr1 > 0
      context.curr1_initial = context.trader_curr1
      context.buy_value = (context.trader_curr1 * context.cur_ins.price) + context.trader_curr2
    else
      context.curr1_initial = context.trader_curr2 / context.cur_ins.price
    context.curr2_initial = context.trader_curr2
    context.price_initial = context.cur_ins.price
    context.value_initial = (context.cur_ins.price * context.trader_curr1) + context.curr2_initial

  @exec_stats: (context) ->
    if context.next_stats == 0 then context.next_stats = context.time
    if context.time >= context.next_stats
      context.next_stats += context.stats_period
      return true

  @report: (context) ->
    data = context.cur_data
    context.time = data.at / 60000
    if (context.stats == 'all' and Stats.exec_stats(context)) or (context.traded and (context.stats == 'both' or context.stats =='all')) or (context.traded and context.stats == 'sell' and context.trade_type == 'sell')
      positions = _.toArray(context.cur_portfolio.positions)
      context.trader_curr1 = positions[0].amount
      context.trader_curr2 = positions[1].amount
      balance = (context.cur_ins.price * context.trader_curr1) + context.trader_curr2
      if not context.trade_value? or _.contains(['buy_amt', 'sell_amt'], context.trade_type)
        value = balance
      else
        value = context.trade_value
      open = context.cur_ins.open[context.cur_ins.open.length - 1]
      high = context.cur_ins.high[context.cur_ins.high.length - 1]
      low = context.cur_ins.low[context.cur_ins.low.length - 1]
      gain_loss = (value - context.value_initial)
      BH_gain_loss = (value - (context.cur_ins.price * context.curr1_initial)).toFixed(2)

      if context.traded is false
        debug "~~~~~~~~~~~~~~~~~~~~~~"
      else
        debug "~"

      if context.balances
        debug "Balance (#{context.currs[1]}): #{balance.toFixed(2)} | #{context.currs[1]}: #{context.trader_curr2.toFixed(2)} | #{context.currs[0]}: #{context.trader_curr1.toFixed(5)}"
      if context.gain_loss
        if context.trader_curr1 > 0 or context.traded
          debug "[G/L] Session: #{gain_loss.toFixed(2)}  | Trade: #{(value - context.buy_value).toFixed(2)}  |  B&H: #{BH_gain_loss}"
        else
          debug "[G/L] Session: #{gain_loss.toFixed(2)}  |  B&H: #{BH_gain_loss}"

      if context.win_loss
        if context.mode == null
          debug "[W/L]: #{context.Strat1_win_cnt}/#{context.Strat1_loss_cnt} ~ #{context.Strat1_win_value.toFixed(2)}/#{context.Strat1_loss_value.toFixed(2)}"
        else
          debug "[W/L] Ichi: #{context.Strat1_win_cnt}/#{context.Strat1_loss_cnt} ~ #{context.Strat1_win_value.toFixed(2)}/#{context.Strat1_loss_value.toFixed(2)} | Scalp: #{context.Strat2_win_cnt}/#{context.Strat2_loss_cnt} ~ $#{context.Strat2_win_value.toFixed(2)}/$#{context.Strat2_loss_value.toFixed(2)}"

      if context.prices
        debug "Price: #{context.cur_ins.price.toFixed(3)} | Open: #{open.toFixed(3)} | High: #{high.toFixed(3)} | Low: #{low.toFixed(3)}"
    context.traded = false
    context.trade_value = null

#    if context.triggers and context.mode == 'ichi'
#      if context.trader_curr1 > 0
#        warn "Long - Close: #{tk_diff.toFixed(3)} >= #{config.long_close} [&] #{c.tenkan.toFixed(3)} <= #{c.kijun.toFixed(3)} [&] (#{c.chikou.toFixed(3)} <= #{sar.toFixed(3)} [or] #{rsi.toFixed(3)} <= #{config.rsi_low} [or] #{macd.histogram.toFixed(3)} <= #{config.macd_short})"
#        warn "Short - Open: #{tk_diff.toFixed(3)} >= #{config.short_open} [&] #{c.tenkan.toFixed(3)} <= #{c.kijun.toFixed(3)} [&] #{tenkan_max.toFixed(3)} <= #{kumo_min.toFixed(3)} [&] #{c.chikou_span.toFixed(3)} <= 0 [&] #{aroon.up} - #{aroon.down} < -#{config.aroon_threshold}"
#      else
#        warn "Short - Close: #{tk_diff.toFixed(3)} >= #{config.short_close} [&] #{c.tenkan.toFixed(3)} >= #{c.kijun.toFixed(3)} [&] (#{c.chikou.toFixed(3)} >= #{sar.toFixed(3)} [or] #{rsi.toFixed(3)} >= #{config.rsi_low} [or] #{macd.histogram.toFixed(3)} >= #{config.macd_long})"
#        warn "Long - Open: #{tk_diff.toFixed(3)} >= #{config.long_open} [&] #{c.tenkan.toFixed(3)} >= #{c.kijun.toFixed(3)} [&] #{tenkan_min.toFixed(3)} >= #{kumo_max.toFixed(3)} [&] #{c.chikou_span.toFixed(3)} >= 0 [&] #{aroon.up} - #{aroon.down} >= #{config.aroon_threshold}"

  @win_loss: (context, trade_result) ->
    trade_net = context.trade_value - context.buy_value
    if context.mode == 'ichi' or context.mode == null
      if trade_net >= 0
        context.Strat1_win_cnt += 1
        context.Strat1_win_value += trade_net
      else
        context.Strat1_loss_cnt += 1
        context.Strat1_loss_value += trade_net
    else if context.mode =='scalp'
      if trade_net >= 0
        context.Strat2_win_cnt += 1
        context.Strat2_win_value += trade_net
      else
        context.Strat2_loss_cnt += 1
        context.Strat2_loss_value += trade_net

  @can_buy: (context) ->
    context.trader_curr2 >= ((context.cur_ins.price * context.min_btc) * (1 + context.fee_percent / 100))

  @can_sell: (context) ->
    context.trader_curr1 >= context.min_btc

  @sell: (context, amt = null) ->
    if Stats.can_sell(context)
      if context.trader_curr1 - context.curr1_reserve > 0
        if _.contains(['all', 'both', 'sell'], context.stats)
          debug "~~~~~~~~~~~~"
        trade_price = context.cur_ins.price * (1 - context.sell_limit_percent / 100)
        if amt?
          trade_amount = _.min([amt, context.trader_curr1 - context.curr1_reserve])
        else
          trade_amount = context.trader_curr1 - context.curr1_reserve
        if trade_result = sell context.cur_ins, trade_amount, trade_price, context.sell_timeout
          context.trade_value = trade_result.amount * trade_result.price
          context.trader_curr2 += context.trade_value
          context.trader_curr1 -= trade_result.amount
          Stats.win_loss(context, trade_result)
          context.traded = true
          if amt? then context.trade_type = 'sell_amt' else context.trade_type = 'sell'

  @buy: (context, amt = null) ->
    if Stats.can_buy(context)
      if context.trader_curr2 - context.curr2_reserve > 0
        if _.contains(['all', 'both', 'sell'], context.stats)
          debug "~~~~~~~~~~~~"
        context.buy_value = (context.trader_curr1 * context.cur_ins.price) + context.trader_curr2
        trade_price = context.cur_ins.price * (1 + context.buy_limit_percent / 100)
        if amt?
          trade_amount = _.min([amt * trade_price, context.trader_curr2 - context.curr2_reserve]) / trade_price
        else
          trade_amount = (context.trader_curr2 - context.curr2_reserve) / trade_price
        if trade_result = buy context.cur_ins, trade_amount, trade_price, context.buy_timeout
          context.trade_value = trade_result.amount * trade_result.price
          context.trader_curr2 -= context.trade_value
          context.trader_curr1 += trade_result.amount
          context.traded = true
          if amt? then context.trade_type = 'buy_amt' else context.trade_type = 'buy'
#
# Context for Stats
#
  @context: (context) ->
    context.stats = 'all'       # Display Stats? all = every stats period , sell = only on sells, both = only on buy or sell, off = no Stats
    context.stats_period = 120  # Display Stats only every n minutes when .stats = 'all'
    context.balances = true     # Display Balances?
    context.gain_loss = true    # Display Gain / Loss?
    context.win_loss = true     # Display Win / Loss?
    context.prices = true       # Display Prices?
  #  context.triggers = false    # Display Trade triggers? *** Temporarily disabled
  #
  # Context for Orders
  #
    context.curr1_reserve = 0         # Reserve curr1
    context.curr2_reserve = 0         # Reserve curr2
  #  context.curr2_limit = null        # curr2 Trading Limit (null = no limit) *** Temporarily disabled
  #
  # Required variables
  #   Comment any defined in the Host strategy code
  #
    context.pair = 'btc_usd'
    context.min_btc = 0.01
    context.fee_percent = 0.6
    context.buy_limit_percent = 0
    context.sell_limit_percent = 0
    context.buy_timeout = 90
    context.sell_timeout = 90
  #
  # DO NOT change anything below
  #
    context.next_stats = 0
    context.time = 0
    context.mins = 0
    context.trade_value = null
    context.cur_ins = null
    context.cur_data = null
    context.cur_portfolio = null
    context.currs = []
    context.trader_curr1 = null
    context.trader_curr2 = null
    context.value_initial = 0
    context.price_initial = 0
    context.curr1_initial = 0
    context.curr2_initial = 0
    context.buy_value = null
    context.traded = false
    context.trade_type = null
    # Ichi/Scalp
    context.mode = null
    # Win & Losses
    context.Strat1_win_cnt = 0
    context.Strat1_win_value = 0
    context.Strat1_loss_cnt = 0
    context.Strat1_loss_value = 0
    context.Strat2_win_cnt = 0
    context.Strat2_win_value = 0
    context.Strat2_loss_cnt = 0
    context.Strat2_loss_value = 0
#
# Serialized Context
#
  @serialize: (context)->
    next_stats:context.next_stats
    cur_ins:context.cur_ins
    cur_data:context.cur_data
    cur_portfolio:context.cur_portfolio
    currs:context.currs
    trader_curr1:context.trader_curr1
    trader_curr2:context.trader_curr2
    value_initial:context.value_initial
    price_initial:context.price_initial
    curr1_initial:context.curr1_initial
    curr2_initial:context.curr2_initial
    traded:context.traded
    Strat1_win_cnt:context.Strat1_win_cnt
    Strat1_win_value:context.Strat1_win_value
    Strat1_loss_cnt:context.Strat1_loss_cnt
    Strat1_loss_value:context.Strat1_loss_value
    Strat2_win_cnt:context.Strat2_win_cnt
    Strat2_win_value:context.Strat2_win_value
    Strat2_loss_cnt:context.Strat2_loss_cnt
    Strat2_loss_value:context.Strat2_loss_value
#
# finalize: method
#
  @finalize: (context)->
    if _.contains(['all', 'both', 'sell'], context.stats)
      context.stats = 'all'
      context.next_stats = 0
      debug "~~~~~~~~~~~~~~~~~~~~~~"
      debug "~  Final Stats"
      Stats.report(context)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#>>>>>>>>>>>>>>>>>>>>>> END MODULES >>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>> START ALGORITM >>>>>>>>>>>>>>>>>>>>


class Init
  @init_context: (context) ->
    context.pair = 'btc_usd'
    context.min_btc = 0.01
    context.fee_percent = 0.6
    context.ha = new HeikinAshi()
    context.ichi_bull = new Ichimoku(8, 11, 11, 11, 10)
    context.ichi_bear = new Ichimoku(7, 10, 11, 11, 42)
    context.config_bull = new Config(
      0.1, -2.18, -0.20, 2.18, #lo/lc/so/sc
      0, 0, #chikou_span-low/high
      0.025, 0.2, #sar-accel/max
      10, 20, #aroon-period/threshold
      10, 21, 8, -1, 1, #macd-fast/slow/sig/low/high
      20, 48, 52 #rsi-period/low/high
    )
    context.config_bear = new Config(
      0.1, -0.3, -0.3, 2.4, #lo/lc/so/sc
      0, -1, #chikou_span-low/high
      0.025, 0.2, #sar-accel/max
      10, 20, #aroon-period/threshold
      14, 22, 9, 0, 1, #macd-fast/slow/sig/low/high
      20, 48, 52 #rsi-period/low/high
    )
    context.bull_market_threshold = -0.75
    context.bear_market_threshold = -0.75
    context.market_short = 12
    context.market_long = 90
    context.enable_ha = true
    context.pos = null
    context.init = true


class Ichimoku
  constructor: (@tenkan_n, @kijun_n, @senkou_a_n, @senkou_b_n, @chikou_n) ->
    @price = 0.0
    @tenkan = 0.0
    @kijun = 0.0
    @senkou_a = []
    @senkou_b = []
    @chikou = []

  # get current ichimoku state
  current: ->
    c =
      price: @price
      tenkan: @tenkan
      kijun: @kijun
      senkou_a: @senkou_a[0]
      senkou_b: @senkou_b[0]
#      chikou: @chikou[0]
      chikou: @chikou[@chikou.length - 1]
      chikou_span: Functions.diff(@chikou[@chikou.length - 1], @chikou[0])
    return c

  # update with latest instrument price data
  put: (ins) ->
    # update last close price
    @price = ins.close[ins.close.length - 1]
    # update tenkan sen
    @tenkan = this._hla(ins, @tenkan_n)
    # update kijun sen
    @kijun = this._hla(ins, @kijun_n)
    # update senkou span a
    @senkou_a.push((@tenkan + @kijun) / 2)
    this._splice(@senkou_a, @senkou_a_n)
    # update senkou span b
    @senkou_b.push(this._hla(ins, @senkou_b_n * 2))
    this._splice(@senkou_b, @senkou_b_n)
    # update chikou span
    @chikou.push(ins.close[ins.close.length - 1])
    this._splice(@chikou, @chikou_n)

  # calc average of price extremes (high-low avg) over specified period
  _hla: (ins, n) ->
    hh = _.max(ins.high[-n..])
    ll = _.min(ins.low[-n..])
    return (hh + ll) / 2

  # restrict array length to specified max
  _splice: (arr, l) ->
    while arr.length > l
      arr.splice(0, 1)


class HeikinAshi
  constructor: () ->
    @ins =
      open: []
      close: []
      high: []
      low: []

  # update with latest instrument price data
  put: (ins) ->
    if @ins.open.length == 0
      # initial candle
      @ins.open.push(ins.open[ins.open.length - 1])
      @ins.close.push(ins.close[ins.close.length - 1])
      @ins.high.push(ins.high[ins.high.length - 1])
      @ins.low.push(ins.low[ins.low.length - 1])
    else
      # every other candle
      prev_open = ins.open[ins.open.length - 2]
      prev_close = ins.close[ins.close.length - 2]
      curr_open = ins.open[ins.open.length - 1]
      curr_close = ins.close[ins.close.length - 1]
      curr_high = ins.high[ins.high.length - 1]
      curr_low = ins.low[ins.low.length - 1]
      @ins.open.push((prev_open + prev_close) / 2)
      @ins.close.push((curr_open + curr_close + curr_high + curr_low) / 4)
      @ins.high.push(_.max([curr_high, curr_open, curr_close]))
      @ins.low.push(_.min([curr_low, curr_open, curr_close]))


class Functions
  @diff: (x, y) ->
    ((x - y) / ((x + y) / 2)) * 100

  @ema: (data, period) ->
    results = talib.EMA
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    _.last(results)

  @sar: (high, low, accel, max) ->
    results = talib.SAR
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInAcceleration: accel
      optInMaximum: max
    _.last(results)

  @sar_ext: (high, low, start_value, offset_on_rev, accel_init_long, accel_long, accel_max_long, accel_init_short, accel_short, accel_max_short) ->
    results = talib.SAREXT
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInStartValue: start_value
      optInOffsetOnReverse: offset_on_rev
      optInAccelerationInitLong: accel_init_long
      optInAccelerationLong: accel_long
      optInAccelerationMaxLong: accel_max_long
      optInAccelerationInitShort: accel_init_short
      optInAccelerationShort: accel_short
      optInAccelerationMaxShort: accel_max_short
    _.last(results)

  @aroon: (high, low, period) ->
    results = talib.AROON
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInTimePeriod: period
    result =
      up: _.last(results.outAroonUp)
      down: _.last(results.outAroonDown)
    result

  @macd: (data, fast_period, slow_period, signal_period) ->
    results = talib.MACD
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInFastPeriod: fast_period
      optInSlowPeriod: slow_period
      optInSignalPeriod: signal_period
    result =
      macd: _.last(results.outMACD)
      signal: _.last(results.outMACDSignal)
      histogram: _.last(results.outMACDHist)
    result

  @rsi: (data, period) ->
    results = talib.RSI
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    _.last(results)

  @populate: (target, ins) ->
    for i in [0...ins.close.length]
      t =
        open: ins.open[..i]
        close: ins.close[..i]
        high: ins.high[..i]
        low: ins.low[..i]
      target.put(t)

  @can_buy: (ins, min_btc, fee_percent) ->
    portfolio.positions[ins.curr()].amount >= ((ins.price * min_btc) * (1 + fee_percent / 100))

  @can_sell: (ins, min_btc) ->
    portfolio.positions[ins.asset()].amount >= min_btc


class Config
  constructor: (@long_open, @long_close, @short_open, @short_close, @chikou_span_low, @chikou_span_high, @sar_accel, @sar_max, @aroon_period, @aroon_threshold, @macd_fast_period, @macd_slow_period, @macd_signal_period, @macd_low, @macd_high, @rsi_period, @rsi_low, @rsi_high) ->



#>>>>>>>>>>>>>>>>>>>>>> END ALGORITM >>>>>>>>>>>>>>>>>>>>

#>>>>>>>>>>>>>>>>>>>>>> BEGIN CORE METHODS >>>>>>>>>>>>>>>>>>>>
# Initialization method called before a bot starts.
# Context object holds script data and will be passed to 'handle' method.
init: (context) ->
  OpenSettings.module_disabler(context)
  Stats.context(context)unless context.OS_module2 == false
  Init.init_context(context)

#This method allows variables to persist after a restart
serialize: (context)->
  Stats.serialize(context)unless context.OS_module2 == false

# This method is called for each tick
handle: (context, data) ->
  Stats.handle(context, data)unless context.OS_module2 == false
  instrument = data.instruments[0]
  SimplePlot.handle(context, data) unless context.OS_module1 == false

  # get instrument
  instrument = data[context.pair]

  # handle instrument data
  if context.init
    if context.enable_ha
      # initialise heikin-ashi
      Functions.populate(context.ha, instrument)
      # initialise ichimoku (from heikin-ashi data)
      Functions.populate(context.ichi_bull, context.ha.ins)
      Functions.populate(context.ichi_bear, context.ha.ins)
    else
      # initialise ichimoku
      Functions.populate(context.ichi_bull, instrument)
      Functions.populate(context.ichi_bear, instrument)
    # initialisation complete
    context.init = false
  else
    if context.enable_ha
      # handle new instrument (via heikin-ashi)
      context.ha.put(instrument)
      context.ichi_bull.put(context.ha.ins)
      context.ichi_bear.put(context.ha.ins)
    else
      # handle new instrument
      context.ichi_bull.put(instrument)
      context.ichi_bear.put(instrument)

  # determine current market condition (bull/bear)
  if context.enable_ha
    short = Functions.ema(context.ha.ins.close, context.market_short)
    long = Functions.ema(context.ha.ins.close, context.market_long)
  else
    short = Functions.ema(instrument.close, context.market_short)
    long = Functions.ema(instrument.close, context.market_long)
  mkt_diff = Functions.diff(short, long)
  is_bull = mkt_diff >= context.bull_market_threshold
  is_bear = mkt_diff <= context.bear_market_threshold

  if is_bull or is_bear
    # market config
    if is_bull
      # bull market
      config = context.config_bull
      c = context.ichi_bull.current()
    else if is_bear
      # bear market
      config = context.config_bear
      c = context.ichi_bear.current()

    # log/plot data
    #  info "tenkan: " + c.tenkan + ", kijun:" + c.kijun + ", senkou_a:" + c.senkou_a + ", senkou_b:" + c.senkou_b
    plot
      short: short
      long: long
      tenkan: c.tenkan
      kijun: c.kijun
      senkou_a: c.senkou_a
      senkou_b: c.senkou_b

    # calc ichi indicators
    tk_diff = Functions.diff(c.tenkan, c.kijun)
    tenkan_min = _.min([c.tenkan, c.kijun])
    tenkan_max = _.max([c.tenkan, c.kijun])
    kumo_min = _.min([c.senkou_a, c.senkou_b])
    kumo_max = _.max([c.senkou_a, c.senkou_b])

    # calc sar indicator
    if context.enable_ha
      sar = Functions.sar(context.ha.ins.high, context.ha.ins.low, config.sar_accel, config.sar_max)
    else
      sar = Functions.sar(instrument.high, instrument.low, config.sar_accel, config.sar_max)

    # calc aroon indicator
    if context.enable_ha
      aroon = Functions.aroon(context.ha.ins.high, context.ha.ins.low, config.aroon_period)
    else
      aroon = Functions.aroon(instrument.high, instrument.low, config.aroon_period)

    # calc macd indicator
    if context.enable_ha
      macd = Functions.macd(context.ha.ins.close, config.macd_fast_period, config.macd_slow_period, config.macd_signal_period)
    else
      macd = Functions.macd(instrument.close, config.macd_fast_period, config.macd_slow_period, config.macd_signal_period)

    # calc rsi indicator
    if context.enable_ha
      rsi = Functions.rsi(context.ha.ins.close, config.rsi_period)
    else
      rsi = Functions.rsi(instrument.close, config.rsi_period)

    # sell options
    if tk_diff <= config.long_close and (c.chikou <= sar or rsi <= config.rsi_low or macd.histogram <= config.macd_low)
      if Functions.can_sell(instrument, context.min_btc)
        #debug 'lc'
        Stats.sell(context, instrument, null) unless context.OS_module2 == false
        sell(instrument) if context.OS_module2 == false

    if tk_diff <= config.short_open and tenkan_max <= kumo_min and c.chikou_span <= config.chikou_span_low and (aroon.up - aroon.down) < -config.aroon_threshold
      if Functions.can_sell(instrument, context.min_btc)
        #debug 'so'
        Stats.sell(context, instrument, null) unless context.OS_module2 == false
        sell(instrument) if context.OS_module2 == false

    # buy options
    if tk_diff >= config.short_close and (c.chikou >= sar or rsi >= config.rsi_high)
      if Functions.can_buy(instrument, context.min_btc, context.fee_percent)
        #debug 'sc'
        Stats.buy(context, instrument, null)unless context.OS_module2 == false
        buy(instrument) if context.OS_module2 == false

    if tk_diff >= config.long_open and (c.chikou >= sar or rsi >= config.rsi_high) and c.chikou_span >= config.chikou_span_high and tenkan_min >= kumo_max and (aroon.up - aroon.down) >= config.aroon_threshold
      if Functions.can_buy(instrument, context.min_btc, context.fee_percent)
        #debug 'lo'
        Stats.buy(context, instrument, null)unless context.OS_module2 == false
        buy(instrument) if context.OS_module2 == false

  #Process Stats
  Stats.report(context)unless context.OS_module2 == false

# This method is only run at the end of a simulation on cryptotrader.org
finalize: (context)->
  Stats.finalize(context)unless context.OS_module2 == false

