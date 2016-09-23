class Price
  
  attr_accessor :code,:base_ccy,:last_price,:bid,:ask,:vwap,:volume,:datetime
  
  def initialize(adj_factor)
    @adj_factor = adj_factor
  end
  
  def adj_bidprice()
    return @bid * (1 - @adj_factor)
  end

  def adj_askprice()
    return @ask * (1 + @adj_factor)
  end
    
  def bid_value  
    return @last_price * @bid
  end

  def ask_value
    return @last_price * @ask
  end
  
end

