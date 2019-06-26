class Dog 

  attr_accessor :name, :breed 
  attr_reader :id 

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def attributes(name:, breed:)
    @name
    @breed
  end
  
  def self.create_table 
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table 
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end


  def save 
    sql = <<-SQL 
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
          SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self.class.find_by_id(@id)
  end
  
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end
  
  def self.find_by_id(id) 
    sql = <<-SQL
          SELECT * 
          FROM dogs
          WHERE id = ?
          SQL
    row = DB[:conn].execute(sql, id)[0]
    hash = {id: row[0], name: row[1], breed: row[2]}
    dog = Dog.new(hash)
    dog
  end
  
  def self.find_by_name(name) 
    sql = <<-SQL
          SELECT * 
          FROM dogs
          WHERE name = ?
          SQL
    row = DB[:conn].execute(sql, name)[0]
    hash = {id: row[0], name: row[1], breed: row[2]}
    dog = Dog.new(hash)
    dog
  end

  def self.find_or_create_by(attribute)
    
  end

  def update
    
  end

end