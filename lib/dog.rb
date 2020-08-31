require 'pry'
class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

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

    def self.drop_table
        sql =  <<-SQL 
      DROP TABLE IF EXISTS dogs 
        SQL
    DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", name, breed)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        # binding.pry
        end
    end

    def self.create(name:, breed:)
        dog = Dog.new(name, breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        new_dog = self.new(name, breed)
        new_dog.id = row[0]
        new_dog.name =  row[1]
        new_dog.breed = row[2]
        new_dog  
      end

      

end
