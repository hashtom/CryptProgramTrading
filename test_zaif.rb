require "zaif"
require "pp"

class Price
  attr_accessor :code,:base_ccy,:last_price,:bid,:ask,:vwap,:volume,:datetime
end

class BrokerZaif

  def initialize()
    @code = "btc"
    @base_ccy = "jpy"
    @api = Zaif::API.new
  end
    
  def get_price
    
    price = Price.new()
    json = @api.get_ticker(@code)
    price.code = @code
    price.base_ccy= @base_ccy
    price.last_price = json['last']
    price.vwap = json['vwap']
    price.bid = json['bid']
    price.ask = json['ask']
    price.datetime = DateTime.now
    
    return price
    
  end
  
zaif = BrokerZaif.new()
pricedata = zaif.get_price
pp pricedata
  
end
