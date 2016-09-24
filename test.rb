require 'net/http'
require 'uri'
require "pp"
require "json"

uri = URI.parse("https://api.bitflyer.jp")
uri.path = '/v1/ticker'
uri.query = ''

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.get uri.request_uri
    json = JSON.parse(response.body)
    pp json
#puts response.body