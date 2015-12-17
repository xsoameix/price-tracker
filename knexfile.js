var config = {
  client: 'postgresql',
  connection: process.env.PG_CONN
};

module.exports = {
  development: config,
  staging: Object.assign(config, {
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  }),
  production: Object.assign(config, {
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  })
};
