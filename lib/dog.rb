require "pry"

class Dog
attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)
  @id, @name, @breed = id, name, breed
end

def self.create_table
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
  );
SQL

DB[:conn].execute(sql)
end

def self.drop_table
sql = <<-SQL
DROP TABLE dogs;
SQL

DB[:conn].execute(sql)
end

def save
  if self.id
    self.update
  else
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  self
end

def update
sql = <<-SQL
UPDATE dogs
SET name = ?, breed = ?
WHERE id = ?
SQL

DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def self.create(hash)
  new_dog = Dog.new(hash)
  new_dog.save
  new_dog
end

def self.new_from_db(row)
  id = row[0]
  name = row[1]
  breed = row[2]
  new_dog = Dog.new(id: id, name: name, breed: breed)
end

def self.find_by_id(id_num)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE id = ?
  LIMIT 1
  SQL

  DB[:conn].execute(sql, id_num).map do |row|
    dog = Dog.new_from_db(row)
  end.first
end

def self.find_or_create_by(hash)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE name = ? AND breed = ?
  LIMIT 1
  SQL

  dog = DB[:conn].execute(sql, hash[:name], hash[:breed])

  if !dog.empty?
    dog_info = dog[0]
    dog = Dog.new_from_db(dog_info)
  else
    dog = Dog.create(hash)
  end
  dog
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE name = ?
  SQL

  DB[:conn].execute(sql, name).map do |row|
    Dog.new_from_db(row)
  end.first
end

end
