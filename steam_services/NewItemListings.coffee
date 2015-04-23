http = require 'http'
zlib = require 'zlib'
Buyer = require './Buyer.coffee'

module.exports =

  host: 'http://steamcommunity.com/'

  recent_path: 'market/recent?country=US&language=english&currency=1'

  interval: 500

  prices: {} #name: median-price

  min_price: 0
  max_price: 5
  threshold: .25

  start: ()->
    console.log "Starting watch over recent items"
    scope = @
    setInterval (()->scope.getRecent scope.host+scope.recent_path, scope), scope.interval

  getRecent: (url, scope)->
    http.get url, (res) ->
      str = ''
      res.on 'data', (chunk)->
        str += chunk
      res.on 'end', ()->
        listings = scope.parseListing str, scope
        scope.checkWorth listings, scope

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

  checkWorth: (listings, scope)->
    for listing in listings
      market_price = scope.prices[listing.name]
      threshold = Math.max scope.threshold, (listing.price/2.0)
      if market_price
        if market_price - listing.price >= threshold
          scope.buy listing, market_price
      else
        scope.updatePrice listing, scope

  buy: (listing, market_price)->
    console.log "BUY!"
    console.log listing
    console.log market_price
    Buyer.buy listing, market_price

  updatePrice: (listing, scope)->
    path = "market/priceoverview/?key=E5DA106B968029665D6788FD539859B3&currency=usd&appid=730&market_hash_name=#{listing.name}"
    http.get scope.host + path, (res) =>
      chunks = []

      res.on 'data', (data)->
        chunks.push data
      res.on 'end', ()->
        buffer = Buffer.concat chunks
        data = buffer.toString()

        try
          data = JSON.parse data
          if data.median_price
            price = parseFloat (data.median_price.split '&#36;')[1]
            scope.prices[listing.name] = price
        catch
          return
