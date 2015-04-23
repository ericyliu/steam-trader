phantom = require 'phantom'

module.exports =

  host: 'http://steamcommunity.com'
  market: '/market'

  refresh_interval: 5000

  prices: {} #name: { median-price }

  start: ()->
    @openPage @host+@market, @watchNewListings

  openPage: (to_open, callback)->
    scope = @
    phantom.create (ph) ->
      ph.createPage (page) ->
        page.open to_open, (status) ->
          page.includeJs "http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", () ->
          console.log "Opened #{to_open} ", status
          callback(page, scope)

  watchNewListings: (page, scope)->
    scope.refreshNewListings page, scope
    setInterval (()=>
      scope.refreshNewListings page, scope
      scope.getNewListings page, scope
      ), scope.refresh_interval

  refreshNewListings: (page, scope)->
    page.evaluate (()->
        return document.getElementById('tabRecentSellListings')
      ), ((result)->
        page.sendEvent('click', result.offsetLeft, result.offsetTop);
      )

  getNewListings: (page, scope)->
    page.evaluate (()->
        listing = document.getElementById('sellListingRows').innerHTML
        if (listing.indexOf('Loading') != -1)
          return listing
        return listing
      ), ((result) ->
        console.log result
        if result.indexOf('Loading') != -1
          setTimeout (()->scope.getNewListings page, scope),500
      )
