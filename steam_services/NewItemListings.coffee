http = require 'http'
zlib = require 'zlib'
Buyer = require './Buyer.coffee'
request = require 'request'
logger = require '../logger.coffee'

logger.verbose = false

module.exports =

  host: 'http://steamcommunity.com/'

  recent_path: 'market/recent?country=US&language=english&currency=1'

  interval: 500

  prices: {} #name: median-price

  testing: false

  min_price: 0 # min price of item to buy
  max_price: 5 # max price of item to buy
  threshold: .10 # minimum difference between price and market price
  method: 'scaling' # scaling or fixed
  scaling: 33 # percentage of difference between price and market price when using scaling method

  # min_price: 0
  # max_price: .6
  # threshold: .1
  # method: 'fixed'

  start: ()->
    console.log "Starting watch over recent items"
    console.log "Testing: #{@testing}    Verbose: #{logger.verbose}"
    console.log "Minimum: #{@min_price}    Maximum: #{@max_price}    Threshold: #{@threshold}    Method: #{@method}"
    console.log "Scaling: #{@scaling}%" if @method is 'scaling'
    scope = @
    setInterval (()->scope.getRecent scope.host+scope.recent_path, scope), scope.interval

  getRecent: (url, scope)->
    http.get url, (res) ->
      str = ''
      res.on 'data', (chunk)->
        str += chunk
      res.on 'end', ()->
        listings = scope.parseListing str, scope
        for listing in listings
          market_price = scope.prices[listing.name]
          if market_price
            scope.checkWorth listing, market_price, scope
          else
            scope.updatePrice listing, scope

  parseListing: (html, scope)->
    try
      listings = []
      tempList = (JSON.parse html).results_html.split 'market_recent_listing_row'
      tempList.splice 0, 1
      for listing in tempList
        if (listing.indexOf '&#36;') != -1
          id = ((listing.split 'listing_')[1].split '"')[0]

          name = (((listing.split 'market_listing_item_name_link" href="')[1].split '"')[0].split '/730/')[1]

          temp = ((listing.split 'market_listing_price_without_fee')[1].split '</span>')[0]
          subtotal = parseFloat ((temp.split '&#36;')[1].split '\t')[0]

          temp = ((listing.split 'market_listing_price_with_fee')[1].split '</span>')[0]
          price = parseFloat ((temp.split '&#36;')[1].split '\t')[0]

          fee = Math.round((price - subtotal) * 100) / 100

          link = ((listing.split 'market_listing_item_name_link" href="')[1].split '"')[0]

          if price >= scope.min_price && price <= scope.max_price
            listings.push {id, name, price, link, subtotal, fee}
      return listings
    catch
      return []

  checkWorth: (listing, market_price, scope)->
    if scope.method is 'scaling'
      ratio = scope.scaling/100.0
      threshold = Math.max scope.threshold, (listing.price * ratio)
    else
      threshold = scope.threshold
    logger.log  "Listing: #{listing.price}    Market: #{scope.round market_price}    Threshold: #{scope.round threshold}    Difference: #{scope.round (market_price - listing.price)}    Item: #{listing.name}" if listing.price < market_price
    if market_price - listing.price >= threshold
      Buyer.buy listing, market_price if !scope.testing
      scope.pseudoBuy listing, market_price if scope.testing

  pseudoBuy: (listing, market_price)->
    listing.median = market_price
    console.log "Buying:"
    console.log listing

  updatePrice: (listing, scope)->
    if listing.name is undefined then return

    path = "market/pricehistory/?key=E5DA106B968029665D6788FD539859B3&currency=usd&appid=730&market_hash_name=#{listing.name}"
    options =
      url: scope.host + path
      headers:
        "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
        # "Accept-Encoding":"gzip, deflate, sdch"
        "Accept-Language":"en-US,en;q=0.8"
        "Connection":"keep-alive"
        "Cookie":"sessionid=c01b249862007bf166913417; recentlyVisitedAppHubs=730; steamCountry=US%7C1e54dacc418185810cdf4b07a4ab56ad; strInventoryLastContext=730_2; webTradeEligibility=%7B%22allowed%22%3A0%2C%22reason%22%3A2048%2C%22allowed_at_time%22%3A1430450895%2C%22steamguard_required_days%22%3A15%2C%22sales_this_year%22%3A47%2C%22max_sales_per_year%22%3A200%2C%22forms_requested%22%3A0%2C%22new_device_cooldown_days%22%3A7%7D; rgDiscussionPrefs=%7B%22cTopicRepliesPerPage%22%3A50%7D; steamLogin=76561198157972814%7C%7C1E03FE46A98CA5C513A3ED43B3F54821539556AC; timezoneOffset=-14400,0; __utma=268881843.1528852380.1429820666.1429894144.1429902192.6; __utmb=268881843.0.10.1429902192; __utmc=268881843; __utmz=268881843.1429845987.2.2.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided)"
        "Host":"steamcommunity.com"
        "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36"

    request.get options, (err, res, body) ->
      if err
        console.log err
        return

      if res.statusCode isnt 200
        console.log options.url
        console.log res.statusCode
        console.log res.statusMessage
        return

      else
        body = JSON.parse body
        market_price = scope.calculateMarketPrice body.prices, listing.link
        scope.prices[listing.name] = market_price
        scope.checkWorth listing, market_price, scope

  calculateMarketPrice: (prices, url) ->
    if prices.length < 5 then return

    startIndex = Math.max (prices.length - 20), 0
    prices = prices.slice startIndex, prices.length
    prices = prices.map (item) -> item[1]
    prices = prices.sort (a,b) -> a - b
    half = Math.floor prices.length/2

    return prices[half]

  round: (float) -> Math.round(float * 100)/100

