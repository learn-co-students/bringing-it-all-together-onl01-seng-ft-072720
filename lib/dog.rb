class Dog

   

attr_accessor :id, :name, :breed

def initialize(name:, breed:, id: nil)
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
    sql = <<-SQL
    DROP TABLE dogs 
SQL

DB[:conn].execute(sql)
end


def save
   # binding.pry
    if self.id 
        self.update
        
    else
 name = self.name
 breed = self.breed
 #binding.pry
        sql = "
        
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        "
        # binding.pry
        DB[:conn].execute(sql, name, breed)
        
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  self
end
        
def self.find_by_name(name)
            sql = <<-SQL
              SELECT *
              FROM dogs
              WHERE name = ?
              LIMIT 1
            SQL
         
            DB[:conn].execute(sql, name).map do |row|
               # binding.pry
               self.new_from_db(row)
            end.first
end

def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, id).map do |row|
       # binding.pry
       self.new_from_db(row)
    end.first
end


def self.new_from_db(row)
hash = {}
hash[:id] = row[0]
hash[:name] = row[1]
hash[:breed] = row[2]

new_dog = self.new(hash)

#binding.pry

  end


def update
    
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)

end


def self.create(hash)
   # binding.pry
    dog = Dog.new(hash)
    dog.save
    dog
end

def self.find_or_create_by(hash)
   # binding.pry
   name = hash[:name]
   breed = hash[:breed]

        test = Dog.find_by_name(name)
     binding.pry
end



end