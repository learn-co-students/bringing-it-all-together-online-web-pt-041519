class Dog 
  
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end  
  
  def self.create_table
    sql = 
      "CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );"
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = "DROP TABLE dogs"
    
    DB[:conn].execute(sql)
  end  
  
  def self.create(attr_hash)
    new_dog = self.new(attr_hash)
    new_dog.save 
    new_dog
  end  
  
  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end  
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?" 
    
    row = DB[:conn].execute(sql, name)[0] 
    self.new_from_db(row)
  end
  
  def self.find_by_id(x)
    sql = "SELECT * FROM dogs WHERE id = ?" 
    
    row = DB[:conn].execute(sql, x)[0] 
    self.new_from_db(row)
  end  
  
  def self.find_or_create_by(attr_hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr_hash[:name], attr_hash[:breed])
    row = dog[0]
    if !dog.empty? 
      new_dog = self.new_from_db(row)
      new_dog
    else  
      new_dog = self.create(attr_hash)
      new_dog
    end  
  end  
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end  
  
  def save
      if self.id == nil
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        
        DB[:conn].execute(sql,self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      else
        self.update
      end  
      self
  end  
end  