# require 'sqlite3'

# class Seeder
#   def self.seed!
#     drop_tables
#     create_tables
#   end

#   def self.drop_tables
#     db.execute('DROP TABLE IF EXISTS asteroids_data')
#   end

#   def self.create_tables

#     db.execute('CREATE TABLE asteroids_data (
#                 id INTEGER PRIMARY KEY AUTOINCREMENT,
#                 name TEXT NOT NULL,
#                 score INTEGER)')
#   end
# end

# Seeder.seed!