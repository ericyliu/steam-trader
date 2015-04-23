http = require 'http'
# ItemListings = require './steam_services/ItemListings.coffee'
# SiteCrawler = require './steam_services/SiteCrawler.coffee'
NewItemListings = require './steam_services/NewItemListings.coffee'
Buyer = require './steam_services/Buyer.coffee'

server = http.createServer (req,res) ->
  res.writeHead 200,
    'Content-Type': 'text/html'
  res.end 'Hello World'

server.listen 9000, 'localhost'

console.log 'Server running at http://localhost:9000'
Buyer.NewItemListings = NewItemListings
Buyer.login 'atrainsmurf', 'aflack5234'
