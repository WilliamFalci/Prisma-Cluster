
'use strict';

const path = require('path')
const dotenv = require('dotenv').config({ path: path.resolve(__dirname, `../CLI/env/.env`) })

const _ = require('lodash');
const jayson = require('jayson');

const { methods } = require('./router.js')

// this reduction produces an object like this: {'foo.bar': [Function], 'math.add': [Function]}
const map = _.reduce(methods, collapse('', '.'), {});

function collapse(stem, sep) {
  return function(map, value, key) {
    const prop = stem ? stem + sep + key : key;
    console.log(prop)
    if(_.isFunction(value)) map[prop] = value;
    else if(_.isObject(value)) map = _.reduce(value, collapse(prop, sep), map);
    return map;
  }
}

const server = new jayson.Server(map);
server.tcp().listen(3000);