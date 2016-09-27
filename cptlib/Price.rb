require "date"

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

class BidAsk
    attr_reader :bidask_type,:price_value,:volume
    
    def initialize(bidask_type,price_value,volume)
      @bidask_type = bidask_type
      @price_value = price_value
      @volume = volume
    end
end

class PriceDepth
  
    attr_accessor :code,:base_ccy,:bidask,:datetime   
  
    def initialize(code,base_ccy)
      @code = code
      @base_ccy = base_ccy
      @datetime = DateTime.now
    end
    
    #def self.add_bidask(bidask)
    #  @bidask.push(bidask)
    #end
    
    def get_bids_tradable(min_trade_size)
      
      #@bidask.select{|p| p.bidask_type=="bids"}.sort{|p| p.price_value}.collect{|p| p}
      trade_size = 0
      bids = Array.new()
      bids_tradable = PriceDepth.new(@code,@base_ccy)
#      while trade_size < min_trade_size
        
        @bidask.select{|p| p.bidask_type=="bids"}.sort{|p| -p.price_value}.collect{|p| p}.each do |p|
          if trade_size < min_trade_size then
            trade_size += p.price_value * p.volume
            bids.push(p)
          end
        end
        
 #     end
      
      bids_tradable.bidask = bids
      
      return bids_tradable
      
    end
  
    def average_price
        trade_size = 0
        total_volume = 0

        @bidask.select{|p| p.bidask_type=="bids"}.collect{|p| p}.each do |p|
          trade_size += p.price_value * p.volume
          total_volume += p.volume 
        end
        return trade_size / total_volume 
    end
    
    def trade_size
        trade_size = 0
        @bidask.select{|p| p.bidask_type=="bids"}.collect{|p| p}.each do |p|
          trade_size += p.price_value * p.volume
        end
        return trade_size
    end
end