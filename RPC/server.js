'use strict';
const _ = require('lodash');
const jayson = require('jayson');
const {methods} = require('./router.js');

const map = _.reduce(methods, collapse('', '.'), {});
const server = new jayson.Server(map);

function collapse(stem, sep) {
  return function(map, value, key) {
    const prop = stem ? stem + sep + key : key;
    if(_.isFunction(value)) map[prop] = value;
    else if(_.isObject(value)) map = _.reduce(value, collapse(prop, sep), map);
    return map;
  }
}

// Bind a http interface to the server and let it listen to localhost:3000
server.tcp().listen(3000);
console.log('listening')