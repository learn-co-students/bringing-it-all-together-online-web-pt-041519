class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
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

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        self.new_from_db(DB[:conn].execute(sql, name).first)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

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
            self
        end
    end

    def self.create(attr_hash)
        dog = self.new(name: nil, breed: nil)
        attr_hash.each {|key, value| dog.send(("#{key}="), value)}
        dog.save
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        self.new_from_db(DB[:conn].execute(sql, id).first)
    end

    def self.find_or_create_by(attr_hash)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])
        if dog.empty?
            self.create(attr_hash)
        else
            self.find_by_name(attr_hash[:name])
        end
    end
end