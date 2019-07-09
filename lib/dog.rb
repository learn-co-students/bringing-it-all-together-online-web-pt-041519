class Dog #class

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name, @breed, @id = name, breed, id
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
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save #not a class
    if self.id
      self.update
    else
      sql = <<-SQL
       INSERT INTO dogs (name, breed)
       VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      dog = Dog.new(name:self.name, breed:self.breed)
      dog
    end
  end

  def self.create(hash) #hash of attribute
    dog = Dog.new(hash)  #create a new student objec
    dog.save
    dog #returns the new object that it instantiated
  end

  def self.new_from_db(row)
# create a new Student object given a row from the database
  # self.new is the same as running Song.new
    id = row[0]
    name = row[1]
    breed = row[2]
  self.new(id: id, name: name, breed: breed)
  end


  def self.find_by_id(id)
  # find the student in the database given a name
  # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
