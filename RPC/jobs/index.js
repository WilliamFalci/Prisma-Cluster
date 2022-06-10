
const path = require('path')
const dotenv = require('dotenv').config({ path: path.resolve(__dirname, `../../CLI/env/.env`) })

// DO NOT ALTER OR DELETE THIS LINE - IMPORT CRON SERVICES

console.log("> Cron Job Server Started...")
testJobs
