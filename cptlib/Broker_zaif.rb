require "zaif"
require "./cptlib/Broker"

class Zaif < Broker
    
  def get_price
    @price
  end
  
end