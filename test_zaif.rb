require "zaif"
require "pp"
require "./cptlib/Broker"
require "./cptlib/Price"

 
zaif = BrokerZaif.new("btc")
pricedata = zaif.get_depth

bids = pricedata.get_bids_tradable(200000)
pp bids.trade_size, bids.average_price
pp bids.bidask