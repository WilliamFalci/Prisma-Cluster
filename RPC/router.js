require('dotenv').config({ path: '../CLI/env/.env' }); // SUPPORT .ENV FILES 

const core = {
  ping: (args,callback) => {
    callback(null, 'pong');
  }
}

// DO NOT ALTER OR DELETE THIS LINE - IMPORT SERVICES METHODS

// Build Service Methods (Router)
let methods = {}
methods = Object.assign(methods,{core: core});

module.exports = {methods}