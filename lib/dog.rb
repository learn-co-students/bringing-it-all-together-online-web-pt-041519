require 'pry'
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end 
  
  def save 
    if self.id
      self.update
    else 
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
        SQL
        
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end 
  
  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end
  
   def self.new_from_db(attributes)
    Dog.new(id: attributes[0], name: attributes[1], breed: attributes[2])
  end 
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    
    dog = DB[:conn].execute(sql, id).flatten
    new_from_db(dog)
  end 
  
  def self.find_or_create_by(name:, breed:)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
    if !dog_data.empty?
      dog = new_from_db(dog_data)
    else 
      dog = self.create(name: name, breed: breed)
    end 
    dog
  end 
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    
    dog = DB[:conn].execute(sql,name).flatten
    new_from_db(dog)
  end 
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
end 