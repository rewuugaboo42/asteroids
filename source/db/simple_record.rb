require_relative 'db_connection'

class SimpleRecord
  def self.table_name
    @table_name ||= self.name.downcase + "s"
  end

  def self.create_table
    columns_definition = {
      'id' => 'INTEGER PRIMARY KEY AUTOINCREMENT',
      'name' => 'TEXT',
      'score' => 'INTEGER'
    }

    cols_sql = columns_definition.map { |col, type| "#{col} #{type}" }.join(", ")

    DB.execute("CREATE TABLE IF NOT EXISTS #{table_name} (#{cols_sql});")
  end

  def initialize(attributes = {})
    @attributes = {}
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def method_missing(name, *args)
    attr = name.to_s
    if attr.end_with?('=')
      @attributes[attr[0..-2]] = args.first
    else
      @attributes[attr]
    end
  end

  def self.columns
    @columns ||= DB.table_info(table_name).map { |col| col['name'] }
  end

  def self.all
    rows = DB.execute("SELECT * FROM #{table_name}")
    rows.map { |row| new(row) }
  end

  def self.find(id)
    row = DB.get_first_row("SELECT * FROM #{table_name} WHERE id = ?", id)
    row ? new(row) : nil
  end

  def save
    if @attributes['id']
      update_record
    else
      insert_record
    end
  end

  def self.create(attrs)
    obj = new(attrs)
    obj.save
    obj
  end

  private

  def insert_record
    cols = @attributes.keys
    vals = @attributes.values
    placeholders = (['?'] * cols.size).join(', ')
    DB.execute("INSERT INTO #{self.class.table_name} (#{cols.join(", ")}) VALUES (#{placeholders})", vals)
    @attributes['id'] = DB.last_insert_row_id
  end

  def update_record
    cols = @attributes.keys - ['id']
    set_clause = cols.map { |col| "#{col} = ?" }.join(', ')
    vals = cols.map { |col| @attributes[col] }
    vals << @attributes['id']
    DB.execute("UPDATE #{self.class.table_name} SET #{set_clause} WHERE id = ?", vals) 
  end
end