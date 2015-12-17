exports.up = function(knex, Promise) {
  return knex.schema.createTable('items', function(t) {
    t.increments('id').primary();
    t.string('name').unique().notNullable();
    t.string('desc').notNullable();
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('items');
};
