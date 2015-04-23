require('coffee-script/register');

var http = require('http');
var NewItemListings = require('./steam_services/NewItemListings.coffee');
var Buyer = require('./steam_services/Buyer.coffee');

var server = http.createServer(function (req,res) {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('Hello World');
});

server.listen(process.env.PORT || 5000);

console.log('Server running at http://localhost:9000');
Buyer.NewItemListings = NewItemListings
Buyer.login('atrainsmurf','aflack5234');
