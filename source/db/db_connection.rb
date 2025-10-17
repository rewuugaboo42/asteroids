require 'sqlite3'

DB = SQLite3::Database.new('database/asteroids_data.sqlite')
DB.results_as_hash = true