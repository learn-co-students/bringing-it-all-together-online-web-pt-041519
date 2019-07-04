class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name: name, breed: breed)
        @id = id
        @name = name
        @breed = breed
    end

    def self.table_name
        "#{self.to_s.downcase}s"
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS #{self.table_name} (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS #{self.table_name}")
    end

    def save
        if self.id 
          self.update
        else
          sql = <<-SQL
            INSERT INTO #{self.class.table_name} (name, breed) 
            VALUES (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
          return self
        end
    end

    def self.create(name: name, breed: breed)
        dog = self.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(dog_arry)
        id = dog_arry[0]
        name = dog_arry[1]
        breed = dog_arry[2]
        self.new(id: id, name: name, breed: breed)
    end


    def self.find_by_id(id)
        sql = "SELECT * FROM #{self.table_name} WHERE id = ?"
        dog = DB[:conn].execute(sql, id)[0]
        self.new_from_db(dog)
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
        dog = DB[:conn].execute(sql, name)[0]
        self.new_from_db(dog)
    end


    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new_from_db(dog_data)
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
    end 
    
    def update
        sql = "UPDATE #{self.class.table_name} SET name = ?, breed = ?, id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end