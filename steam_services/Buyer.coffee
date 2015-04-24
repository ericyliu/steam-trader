http = require 'http'
zlib = require 'zlib'
Steam = require 'steam'
fs = require 'fs'
request = require 'request'
FormData = require 'form-data'

cookies = []

module.exports =

  host: 'https://steamcommunity.com'
  buy_url: "/market/buylisting"
  sell_url: "/market/sellitem/"
  bot: undefined
  buying: false

  sessionid: "c01b249862007bf166913417"
  Cookie: "steamMachineAuth76561198157972814=B66B6B17F9D352423A1B430B99152F41BA1222C0; sessionid=c01b249862007bf166913417; steamCountry=US%7Cafa558678a69a60e7d4d227198d45b80; steamLogin=76561198157972814%7C%7C1E03FE46A98CA5C513A3ED43B3F54821539556AC; steamLoginSecure=76561198157972814%7C%7C4B4A2F4C4A0FB85449403883529F44B4EC31B0D2; webTradeEligibility=%7B%22allowed%22%3A1%2C%22allowed_at_time%22%3A0%2C%22steamguard_required_days%22%3A15%2C%22sales_this_year%22%3A0%2C%22max_sales_per_year%22%3A200%2C%22forms_requested%22%3A0%2C%22new_device_cooldown_days%22%3A7%7D; timezoneOffset=-14400,0; __utma=268881843.1528852380.1429820666.1429820666.1429845987.2; __utmb=268881843.0.10.1429845987; __utmc=268881843; __utmz=268881843.1429845987.2.2.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided)"

  login: (username, password)->
    NewItemListings = @NewItemListings
    NewItemListings.start()

    # options =
    #   url: "http://steamcommunity.com"
    #   headers:
    #     "Host":"steamcommunity.com"
    #     "Referer":"http://steamcommunity.com/"
    #     "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36"

    # request.get options, (err, res, body) ->
    #   if err
    #     console.log err
    #     return

    #   if res.statusCode isnt 200
    #     console.log res.statusCode
    #     console.log body
    #     return

    #   if res.statusCode is 200
    #     console.log "Connected to steam community"
    #     for cookie in res.headers['set-cookie']
    #       c = cookie.split(' ')[0]
    #       cookies.push c

    #     options =
    #       url: "https://store.steampowered.com/login/transfer"
    #       headers:
    #         "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    #         "Accept-Encoding":"gzip, deflate"
    #         "Accept-Language":"en-US,en;q=0.8"
    #         "Cache-Control":"max-age=0"
    #         "Connection":"keep-alive"
    #         "Content-Type":"application/x-www-form-urlencoded"
    #         "Cookie":"browserid=680371024058544717; lastagecheckage=1-January-1985; sessionid=bebba5b60b2a4d420cfd297c; dp_user_language=1; steamMachineAuth76561198157972814=E29FDF60BA3FE93588739517099AFC311E01A180; recentapps=%7B%22730%22%3A1429645620%2C%22255710%22%3A1429643023%2C%22268670%22%3A1426267199%2C%22273350%22%3A1423678746%2C%22331200%22%3A1423671562%2C%22241560%22%3A1417544623%7D; dp_user_sessionid=b179d46762b54e6053e1d062ffe67532; app_impressions=325610@1_4_4__40|255710@1_4_4__100|291650@1_4_4__123|329530@1_4_4__123|327890@1_4_4__123|219740@1_4_4__40|209080@1_4_4__131|255710@1_4_4__100|350070@1_4_4__123|291650@1_4_4__123|307210@1_4_4__123|219740@1_4_4__40|242860@1_4_4__131|353380@1_4_4__100|318230@1_4_4__123|285740@1_4_4__123|291650@1_4_4__123|219740@1_4_4__40|209080@1_4_4__131|237990@1_4_4__100|285740@1_4_4__123|363220@1_4_4__123|307210@1_4_4__123|219740@1_4_4__40|240@1_4_4__131|236390@1_4_4__100|307210@1_4_4__123|350070@1_4_4__123|291650@1_4_4__123|219740@1_4_4__40|219640@1_4_4__131|236390@1_4_4__100|316080@1_4_4__123|307210@1_4_4__123|350070@1_4_4__123|255710@1_4_4__100_1|222880@1_4_4__128_2|209080@1_4_4__128_3|237990@1_4_4__100_4|353380@1_4_4__100_5|357780@1_4_4__130_6|226840@1_4_4__130_7|352080@1_4_4__130_8|329460@1_4_4__130_9|295590@1_4_4__130_10|297130@1_4_4__130_11|275200@1_4_4__130_12|361700@1_4_4__130_13|327890@1_4_4__130_14; timezoneOffset=-14400,0; __utma=128748750.2141254592.1417544625.1429745326.1429758095.12; __utmc=128748750; __utmz=128748750.1429745326.11.11.utmcsr=steamcommunity.com|utmccn=(referral)|utmcmd=referral|utmcct=/market/listings/730/Sawed-Off%20%7C%20Snake%20Camo%20(Well-Worn); steamCountry=US%7C1e54dacc418185810cdf4b07a4ab56ad"
    #         "Host":"store.steampowered.com"
    #         "Origin":"https://steamcommunity.com"
    #         "Referer":"https://steamcommunity.com/login/home/?goto=0"
    #         "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36"
    #       form:
    #         steamid: '76561198157972814'
    #         token: '1E03FE46A98CA5C513A3ED43B3F54821539556AC'
    #         auth: '7ef76564ba853fcb9c49181f70d8bc2d'
    #         remember_login: 'false'
    #         token_secure: '4B4A2F4C4A0FB85449403883529F44B4EC31B0D2'

    #     request.post options, (err, res, body) ->
    #       if err
    #         console.log err
    #         return

    #       if res.statusCode isnt 200
    #         console.log res.statusCode
    #         console.log body
    #         return

    #       console.log res.headers
    #       for cookie in res.headers['set-cookie']
    #         c = cookie.split(' ')[0]
    #         cookies.push c

    #       console.log cookies
    #       NewItemListings.start()

  buy: (listing, median)->
    return if @buying

    listing.subtotal *= 100
    listing.price *= 100
    listing.fee *= 100

    options =
      url: "#{@host}#{@buy_url}/#{listing.id}"
      headers:
        "Cookie": @Cookie
        "Accept": "*/*"
        "Accept-Encoding": "gzip, deflate"
        "Connection": "keep-alive"
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        "Host": "steamcommunity.com"
        "Origin": "http://steamcommunity.com"
        "Referer": "http://steamcommunity.com/market"
        "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36"
      form:
        listingid: listing.id
        sessionid: @sessionid
        currency: 1
        subtotal: listing.subtotal
        fee: listing.fee
        total: listing.price
        quantity: 1

    listing.median = median

    request.post options, @buildBuyCallback(listing,@)

  buildBuyCallback: (info,scope) ->
    buyCallback = (err,httpResponse,body) ->

      logged = '---------------------------------------------------------------------\n'
      logged += "#{info.name}\n"
      info.price /= 100.0
      logged += "#{info.price} / #{info.median}\n"

      if httpResponse.statusCode is 200
        fs.appendFile 'purchases.log', logged, () ->
          console.log logged + '*** SUCCESS ***\nSaved'
        # scope.sell scope
      else if httpResponse.statusCode is 502
        console.log logged + "FAIL: #{httpResponse.body}"
      else
        console.log logged + "ERROR: Something Failed"
    buyCallback

  sellall: (scope) ->

    scope.getInventory scope


    options =
      url: "#{@host}#{sell_url}"
      headers:
        "Cookie": scope.Cookie
        "Accept": "*/*"
        "Accept-Encoding": "gzip, deflate"
        "Connection": "keep-alive"
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        "Host": "steamcommunity.com"
        "Origin": "http://steamcommunity.com"
        "Referer": "http://steamcommunity.com/market"
        "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36"
      form:
        sessionid: scope.sessionId,
        appid: item.appid,
        contextid: item.contextid,
        assetid: item.id,
        amount: 1,
        price: info.price - 1

  getInventory: (scope) ->

