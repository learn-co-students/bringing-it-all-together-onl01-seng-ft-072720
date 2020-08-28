require 'pry'

class Dog
attr_accessor :name, :breed
attr_reader :id

def initialize(id: nil, name:, breed:)
@id= id
@name = name
@breed = breed
end

def self.create_table
sql = <<-SQL
CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
);
SQL

DB[:conn].execute(sql)
end

def self.drop_table
sql = <<-SQL
DROP TABLE IF EXISTS dogs;
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
sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def self.create(name:, breed:)
    d = Dog.new(name: name, breed: breed)
    d.save
    d
end

def self.new_from_db(row)
    d = self.new(id: row[0], name:row[1], breed: row[2])
    d  
end

def self.find_by_id(id)
sql = <<-SQL
SELECT * FROM dogs WHERE id = ?
SQL

d = DB[:conn].execute(sql, id).map do |row|
    # binding.pry
  self.new_from_db(row)
end
d[0]
end

def self.find_by_name(name)
sql = <<-SQL
SELECT * FROM dogs WHERE name = ?
SQL
    
   d = DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
    end
    d[0]
end

def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(dog_data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
end

end