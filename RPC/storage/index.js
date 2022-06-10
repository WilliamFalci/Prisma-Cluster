const fs = require('fs');
if (!fs.existsSync(`${__dirname}/buckets`)){
    fs.mkdirSync(`${__dirname}/buckets`);
}

// DO NOT ALTER OR DELETE THIS LINE - IMPORT STORAGE SERVICES
const storage_default = require('filestorage').create('./buckets/default');

module.exports = {
  storage_default
}
