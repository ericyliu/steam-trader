q = require 'q'
http = require 'http'
request = require 'request'
$ = require('jquery')(require("jsdom").jsdom().parentWindow)
zlib = require 'zlib'

module.exports =

  listings: {} # name : { price, link, update_rate }
  time: 0 #seconds
  turn: 0

  initListings: (game_id)->
    console.log 'Retrieving listings from steam marketplace'
    @getListings game_id, 0

  getListings: (game_id, start)->
    startTime = new Date()
    count = 100
    options =
      host: 'steamcommunity.com'
      path: "/market/search/render/?query=&start=#{start}&count=#{count}&search_descriptions=0&sort_column=price&sort_dir=desc&appid=#{game_id}&category_730_ItemSet%5B%5D=any&category_730_TournamentTeam%5B%5D=any&category_730_Weapon%5B%5D=any"
    http.get options, (res) =>
      str = ''
      res.on 'data', (chunk)->
        str += chunk
      res.on 'end', ()=>
        stopTime = new Date()
        timeDiff = Math.abs(stopTime.getTime() - startTime.getTime())
        console.log "Listing Query Time: #{timeDiff}ms (#{(timeDiff / 1000) % 60}s) for #{count} querys."
        @onListingResponse str, @

  onListingResponse: (data, scope)=>
    try
      data = JSON.parse data
      scope.parseListings data.results_html, scope
      # scope.cullListings min, max
      console.log "Recieved #{(Object.keys scope.listings).length} listings."
      scope.autoUpdate 1
      # Take out Later
      scope.update 0, scope
    catch
     console.log data

  parseListings: (data, scope)=>
    html_listings = data.split 'market_listing_row_link'
    # get rid of header
    html_listings.splice 0, 1
    for html_listing,index in html_listings
      link = ((html_listing.split 'href="')[1].split '" id=')[0]
      price = parseFloat (((html_listing.split '&#36;')[1].split '</span>')[0])
      name = encodeURI (((html_listing.split '"market_listing_item_name"')[1].split '>')[1].split '</span')[0]
      scope.listings[name] = { link, price }


  autoUpdate: (starting_interval)->
    index = 0
    for name,listing of @listings
      listing.update_turn = index
      index++
      if index>10
        index = 0

    step = 5000
    setInterval (()=> @update(step, @)), step

  update: (step, scope)=>
    console.log "Updating Group #{scope.turn}"
    scope.listGoodBuys scope
    requests = []
    for name,listing of scope.listings
      if listing.update_rate is @turn
        requests.push "/market/priceoverview/?key=E5DA106B968029665D6788FD539859B3&currency=usd&appid=730&market_hash_name=#{name}"
    scope.updateListing requests, scope
    scope.turn++
    if scope.turn>10
      turn = 0
    @time+=step/1000

  listGoodBuys: (scope) =>
    for name, listing of scope.listings
      if listing.market_price != undefined
        if listing.market_price > listing.price
          console.log 'Good Buy!'
          console.log decodeURI name
          console.log listing.link

  updateListing: (requests, scope)->
    host = 'steamcommunity.com'
    promises = for request in requests
      @makeRequest host, request, scope

  makeRequest: (host, path, scope)->
    options = {host, path}
    http.get options, (res) =>
      chunks = []

      res.on 'data', (data)->
        chunks.push data
      res.on 'end', ()->
        buffer = Buffer.concat chunks
        encoding = res.headers['content-encoding']
        if encoding is 'gzip'
          zlib.gunzip buffer, (err, decoded) ->
            data = decoded && decoded.toString()
        else if encoding is 'deflate'
          zlib.inflate buffer, (err, decoded) ->
            data = decoded && decoded.toString()
        else
          data = buffer.toString()

        try
          data = JSON.parse data
          name = path.split('market_hash_name=')[1]
          scope.listings[name].price = data.lowest_price
          if data.median_price
            scope.listings[name].market_price = parseFloat (data.median_price.split '&#36;')[1]
        catch
          console.log data



  listHTML: ()->
    html = "<html><div> Name - Price - Market Price: Link</div>"
    for name, listing of @listings
      html += "<div>#{decodeURI name} - #{listing.price} - #{listing.market_price}: #{listing.link}</div>"
    html += "</html>"
    html
