http = require 'http'
zlib = require 'zlib'
Steam = require 'steam'
fs = require 'fs'
request = require 'request'
FormData = require 'form-data'

module.exports =

  host: 'https://steamcommunity.com'
  buy_url: "/market/buylisting"
  bot: undefined
  buying: false

  login: (username, password)->
    console.log "Logging in with #{username} - #{password}"
    keyfile = username+'.key'

    steamGuard = ''
    if fs.existsSync keyfile
      steamGuard = fs.readFileSync keyfile

    @bot = new Steam.SteamClient()
    @bot.logOn
      accountName: username
      password: password
      # authCode: 'XQPCM'
      shaSentryfile: steamGuard
    bot = @bot
    NewItemListings = @NewItemListings

    @bot.on 'loggedOn', () ->
      console.log "Logged In To Steam"
    @bot.on 'error', (error) ->
      console.log error
    @bot.on 'sentry', (sentry) ->
      console.log 'Sentry'
      console.log sentry
      console.log sentry.toString()
      fs.writeFile keyfile, sentry, (err) ->
        if err
          console.log err
        else
          console.log 'Saved';

    @bot.on 'webSessionID', (id) ->
      bot.sessionid = id
      bot.webLogOn (cookies) ->
        bot.cookies = cookies
        console.log "Logged in to community"
        NewItemListings.start()



  buy: (listing, median)->
    return if @buying
    @bot.sessionid = '62f3fb4427bd10e31df31076'

    listing.subtotal *= 100 if listing.subtotal < 1
    listing.price *= 100 if listing.price < 1
    listing.fee *= 100 if listing.fee < 1

    params = "sessionid=" + @bot.sessionid + "&listingid=" + listing.id + "&currency=1" + "&subtotal=" + listing.subtotal + "&fee=" + listing.fee + "&total=" + listing.total

    # form = new FormData()
    # form.append 'listingid', listing.id
    # form.append 'sessionid', @bot.sessionid
    # form.append 'currency', '1'
    # form.append 'subtotal', listing.subtotal
    # form.append 'fee', listing.fee
    # form.append 'total', listing.price
    # form.append 'quantity', '1'

    options =
      url: "#{@host}#{@buy_url}/#{listing.id}"
      headers:
        "Content-type": "application/x-www-form-urlencoded"
        "Cookie": "sessionid=62f3fb4427bd10e31df31076; steamMachineAuth76561198157972814=E29FDF60BA3FE93588739517099AFC311E01A180; rgDiscussionPrefs=%7B%22cTopicRepliesPerPage%22%3A30%7D; recentlyVisitedAppHubs=730; steamCountry=US%7Cafa558678a69a60e7d4d227198d45b80; steamLogin=76561198157972814%7C%7C1E03FE46A98CA5C513A3ED43B3F54821539556AC; steamLoginSecure=76561198157972814%7C%7C4B4A2F4C4A0FB85449403883529F44B4EC31B0D2; webTradeEligibility=%7B%22allowed%22%3A1%2C%22allowed_at_time%22%3A0%2C%22steamguard_required_days%22%3A15%2C%22sales_this_year%22%3A0%2C%22max_sales_per_year%22%3A200%2C%22forms_requested%22%3A0%2C%22new_device_cooldown_days%22%3A7%7D; strInventoryLastContext=730_2; timezoneOffset=-14400,0; __utma=268881843.1884428193.1422993301.1429722490.1429731665.12; __utmb=268881843.0.10.1429731665; __utmc=268881843; __utmz=268881843.1429719388.10.8.utmcsr=csgolounge.com|utmccn=(referral)|utmcmd=referral|utmcct=/"
        "Host": "steamcommunity.com"
        "Accept": "*/*"
        "Accept-Encoding": "gzip, default"
        "Connection": "keep-alive"
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        "Host": "steamcommunity.com"
        "Origin": "http://steamcommunity.com"
        "Referer": "http://steamcommunity.com/market"
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36"
      form:
        listingid: listing.id
        sessionid: @bot.sessionid
        currency: 1
        subtotal: listing.subtotal
        fee: listing.fee
        total: listing.price
        quantity: 1

    request.post options, @buyCallback
    console.log "Sent buy request"

  buyCallback: (err,httpResponse,body) =>
    if httpResponse.statusCode is 200
      console.log "Success Bought"
    else if httpResponse.statusCode is 502
      console.log "Stolen"
    else
      console.log "God damnit steam"
