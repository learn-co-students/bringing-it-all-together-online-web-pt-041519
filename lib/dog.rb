require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  # Create dogs table
  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql) 
  end

  # Drop dogs table
  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)  
  end

  # Create new dog instance and save to database
  def save 
    if self.id 
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

      dog = Dog.new(id:@id, name: self.name, breed: self.breed)
      return dog
    end
  end

  # Update database
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  # Create new dog object from attributes hash, then save
  def self.create(attributes)
    dog = self.new(name:"#{attributes[:name]}", breed:"#{attributes[:breed]}")
    # attributes.each {|key, value| self.send(("#{key}="), value)}
    dog.save
  end

  # Find dog by id
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id).first
    # self.new(id:result[0], name:result[1], breed:result[2])
    self.new_from_db(row)
  end	

  # Find dog or create new by name and breed; return dog
  def self.find_or_create_by(name:, breed:)

    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    
    # If dog isn't empty, create new object from database
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    return dog
  end

  # Create new dog instance with attributes
  def self.new_from_db(row)
    dog = self.new(id:row[0], name:row[1], breed:row[2])
    return dog
  end

  # Find dog by name
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name).first
    self.new_from_db(row)
  end	

end
