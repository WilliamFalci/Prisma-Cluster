
const path = require('path')
const dotenv = require('dotenv').config({ path: path.resolve(__dirname, `../../CLI/env/.env`) })

console.log("> Cron Job Server Started...")

// DO NOT ALTER OR DELETE THIS LINE - IMPORT CRON SERVICES