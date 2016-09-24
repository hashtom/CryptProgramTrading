require "zaif"
#require "json"
require "date"
require 'net/http'
require 'uri'
require "./cptlib/Price"
require "./cptlib/Order"
require "config.rb"

class Broker

attr_accessor :price,:broker_code
attr_reader :broker_code

  
  def initialize(code)
    @code = code
  end

  def get_price
    @price = Price.new()
    @price  
  end
  
  def calcel_all
    
  end
  
  def place_order(order)
    @order = order
  end
  
  def calcel_order(order)
    @order = order
  end
  
end

class BrokerZaif < Broker

  def initialize(code)
    @code = code
    @broker_code = "ZAIF"
    @api = Zaif::API.new
  end
    
  def get_price
    
    price = Price.new(ZAIF_ADJ_FACTOR)

    json = @api.get_ticker(@code)

    price.code = @code
    price.last_price = json['last']
    price.vwap = json['vwap']
    price.bid = json['bid']
    price.ask = json['ask']
    price.datetime = DateTime.now
    
    return price
    
  end
  
  def place_order(order)

  end
  
  def calcel_order(order)

  end
  
end

class BrokerBitFlyer < Broker
  
  def initialize()
    @code = "btc"
    @base_ccy = "jpy"
  end
    
  def get_price

    uri = URI.parse("https://api.bitflyer.jp")
    uri.path = '/v1/ticker'
    uri.query = ''
    
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    response = https.get uri.request_uri
    json = JSON.parse(response.body)
    
    price = Price.new()
    price.code = @code
    price.base_ccy= @base_ccy
    price.last_price = json['ltp']
    price.bid = json['best_bid']
    price.ask = json['best_ask']
    price.datetime = json['timestamp']
    
   return price

end