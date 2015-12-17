exports.up = function(knex, Promise) {
  return knex.schema.createTable('amazon_price', function(t) {
    t.increments('id').primary();
    t.integer('item_id', 8, 2).references('items.id').notNullable();
    t.decimal('amazon', 8, 2).notNullable();
    t.decimal('new', 8, 2);
    t.decimal('used', 8, 2);
    t.decimal('refurbished', 8, 2);
    t.dateTime('recorded_time').notNullable();
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('amazon_price');
};
