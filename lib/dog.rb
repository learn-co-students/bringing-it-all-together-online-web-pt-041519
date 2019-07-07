class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    self.name, self.breed, self.id = name, breed, id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
    self
  end

  def self.create(attributes)
    self.new(name: attributes[:name], breed: attributes[:breed]).tap(&:save)
  end

  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    self.new_from_db(dog)
  end

  def self.find_or_create_by(attributes)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"

    dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).flatten

    !dog.empty? ? self.new_from_db(dog) : self.create(attributes)
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
