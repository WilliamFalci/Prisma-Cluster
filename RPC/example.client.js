
'use strict';
const jayson = require('jayson');

// create a client
const client = new jayson.client.tcp({
  port: 3000
});

// invoke "ping"
client.request('core.ping', [1, 1], function(err, response) {
  if(err) throw err;
  console.log(response);
});