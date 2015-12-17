export knex = require('knex') do
  client: 'postgresql'
  connection: process.env.PG_CONN
