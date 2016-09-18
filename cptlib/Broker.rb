require "./cptlib/Price"

class Broker

attr_accessor :price
attr_reader :broker_code

  
  def initialize(broker_code)
    @broker_code = broker_code
  end

  def get_price

    @price = Price.new()
    @price.code="BTC"
    @price.last_price=70000
  
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