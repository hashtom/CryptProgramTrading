require 'net/https'
require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'open-uri'
require 'time'
 
require 'rubygems'
require 'sqlite3'
 
 
 
# ---------------------------------------------
# 設定はここから
dbname = "miseita.db"
order_kakaku = 0.05  #(例0.25% => 0.0025 現在の価格が50000jpy/btcの場合 => 49875jpy/btcでオーダーを行います。)
btc_kakaku = 0.5 #注文するトータルbtc ※分けて注文する時に１回の注文が0.01btc以下になる場合は強制的に0.01btcでオーダーします。
order_kaisu = 3 #分けて注文する回数
cancel_wait_time = 60 #注文してからキャンセルを行う時間(秒)
@automatic_canceling = 5 #自動的にキャンセル処理を行う時間(分)
sell_buy = 1 # 1はbtcの購入 2はbtcの販売 3は両方 ※まだ実装していません。
@bitflyer_key = "aaaaaaaaaaaaaa"
@bitflyer_secret = "bbbbbbbbbbbbbbbb"
@stock_or_fx = "BTC_JPY" #fxを行う場合は"FX_BTC_JPY"に変更
 
# 設定ここまで
# ---------------------------------------------
 
 
 
#bitflyerのticker
  bitflyer_content = open("https://api.bitflyer.jp/v1/getticker").read
  bitflyer_json_data = JSON.parse(bitflyer_content)
#bitflyerのbidとaskを取り出す
  bitflyer_bid = bitflyer_json_data["best_bid"] #bitcoinを売る時
  bitflyer_ask = bitflyer_json_data["best_ask"] #bitcoinを買う時
 
 
def bitflyer_info #bitflyerのbalanceAPI
# balanceの確認
puts "balanceの確認開始"
  key = @bitflyer_key
  secret = @bitflyer_secret
  uri = URI.parse "https://api.bitflyer.jp/v1/me/getbalance"
  method = "GET"
  path = "/v1/me/getbalance"
  nonce = Time.now.to_i.to_s
  body = "hoge=foo"
  message = nonce + method.to_s + path.to_s# + body
  signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, message)
  headers = {
    "ACCESS-KEY" => key,
    "ACCESS-TIMESTAMP" => nonce,
    "ACCESS-SIGN" => signature,
    "Content-Type" => "application/json"
  }
 
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  response = https.get(uri, headers)
 
  body = response.body
  @balance_json_data = JSON.parse(body)
  puts  @balance_json_data
 
  #ブロックが分かれている時の処理。
  # puts json_data[0]["currency_code"]
  # 結果 => JPY
  # puts  json_data[1]["currency_code"]
  # 結果 => BTC
 #  [{"currency_code"=>"JPY", "amount"=>34551.0, "available"=>34551.0},
 # {"currency_code"=>"BTC", "amount"=>0.01, "available"=>0.01}]
 puts "balanceの確認完了"
#balanceの確認ここまで
 
end
 
puts "注文出来るか確認します。"
 
bitflyer_info
 
 
total_purchase_volume = btc_kakaku * bitflyer_ask
 
if total_purchase_volume > @balance_json_data[0]["amount"]
  puts "JPYの予算不足為プログラムを回せません。"
  exit
else
  puts "JPY予算大丈夫なのでプログラムを回します。"
end
 
 
 
 
def bitflyer_order(order_price, order_btc_value) #bitflyerの売買API
 
  key = @bitflyer_key
  secret = @bitflyer_secret
  order_price = order_price.to_f.round
  order_btc_value = 0.01 if order_btc_value <= 0.01
  order_btc_value = order_btc_value.to_f.round(2)
  uri = URI.parse "https://api.bitflyer.jp/v1/me/sendchildorder"
  method = "POST"
  path = "/v1/me/sendchildorder"
  nonce = Time.now.to_i.to_s
  body = {
  "product_code" => @stock_or_fx,
  "child_order_type" => "LIMIT",
  "side" => "BUY",
  "price" => order_price,
  "size" => order_btc_value,
  "minute_to_expire" => @automatic_canceling,
  "time_in_force" => "GTC"
  }
 
 
  message = nonce + method.to_s + path.to_s + body.to_json
  signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, message)
  headers = {
    "ACCESS-KEY" => key,
    "ACCESS-TIMESTAMP" => nonce,
    "ACCESS-SIGN" => signature,
    "Content-Type" => "application/json"
  }
 
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
 
 
  request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
  request.body = body.to_json
 
 
  response = https.request(request)
  # puts response.body
  @bitflyer_order_json_data = JSON.parse(response.body)
  puts @bitflyer_order_json_data
  # order.buy_order_id = bitflyer_json_data["child_order_acceptance_id"]
  #{"child_order_acceptance_id":"JRF20151214-112159-071645"}
 
end
 
 
def bitflyer_cancel(child_order_acceptance_id) #bitflyerの売買API
 
  key = @bitflyer_key
  secret = @bitflyer_secret
  child_order_acceptance_id = child_order_acceptance_id
  uri = URI.parse "https://api.bitflyer.jp/v1/me/cancelchildorder"
  method = "POST"
  path = "/v1/me/cancelchildorder"
  nonce = Time.now.to_i.to_s
  body = {
  "product_code" => @stock_or_fx,
  "child_order_acceptance_id" => child_order_acceptance_id
  }
 
  message = nonce + method.to_s + path.to_s + body.to_json
  signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, message)
  headers = {
    "ACCESS-KEY" => key,
    "ACCESS-TIMESTAMP" => nonce,
    "ACCESS-SIGN" => signature,
    "Content-Type" => "application/json"
  }
 
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
 
  request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
  request.body = body.to_json
 
 
  response = https.request(request)
 
end
 
 
 
# create table
# 最初の一回目にdbを作成処理を行う。
if File.exist?(dbname)
 
  puts dbname + "が存在します。"
  db = SQLite3::Database.new(dbname)
 
else
 
  puts dbname + "が存在しないので作成します。"
  db = SQLite3::Database.new(dbname)
 
  sql = <<-SQL
    create table btc_order (
      id integer primary key,
      child_order_acceptance_id varchar(200),
      order_jpy_price integer,
      order_btc_value integer,
      order_time varchar(200)
    );
  SQL
 
  db.execute(sql)
 
end
 
 
#---------------------------------------------
 
puts "現在の1BTCのbitflyerのJPY価格 " + bitflyer_ask.to_f.to_s
 
 
x = bitflyer_ask.to_f * order_kakaku.to_f
y = bitflyer_ask.to_f - x.to_f
 
order_kaisu1 = order_kaisu + 1
c = btc_kakaku.to_f / order_kaisu1.to_f / order_kaisu.to_f
 
n = 1
order_kaisu.times do
 puts "BTCの購入開始"
 puts "回数".to_s + n.to_s
 puts "注文値段".to_s + y.to_s
 cx = c * n * 2
 puts "BTC量".to_s + cx.to_f.to_s
#btcの注文開始
 
bitflyer_order(y.to_s, cx.to_f)
return_id = @bitflyer_order_json_data["child_order_acceptance_id"]
puts "注文番号 " + return_id
 
 
#dbへの保存開始
now_time = Time.now
sql = "insert into btc_order(child_order_acceptance_id, order_jpy_price, order_btc_value, order_time) values (:child_order_acceptance_id, :order_jpy_price, :order_btc_value, :order_time)"
db.execute(sql, :child_order_acceptance_id => return_id, :order_jpy_price => y, :order_btc_value => cx.to_f, :order_time => now_time.to_s)
#db保存ここまで
 y = y - x
 n = n + 1
end
puts cancel_wait_time.to_s + "秒後にキャンセルを開始します。"
sleep(cancel_wait_time)
puts "キャンセルを開始します。"
db.results_as_hash = true
sql_select = 'select * from btc_order order by rowid DESC limit ' + order_kaisu.to_s
db.execute(sql_select) do |row|
  child_order_acceptance_id = row["child_order_acceptance_id"].to_s
  bitflyer_cancel(child_order_acceptance_id)
  puts child_order_acceptance_id + "の注文をキャンセルしました。"
 
end