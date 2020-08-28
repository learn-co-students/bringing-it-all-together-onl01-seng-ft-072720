class Dog 
  
  attr_accessor :id, :name, :breed 
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name
    @breed = breed 
  end
  
  def self.create_table 
    sql = <<-SQL
    Create Table If Not Exists dogs (
    id Integer Primary Key,
    name Text
    breed Text)
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    Drop Table dogs
    SQL
    DB[:conn].execute(sql)
  end
  
  def save
    if self.id
      self.update
    else 
      sql = <<-SQL
      Insert Into dogs(name, breed) Values (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("Select last_insert_rowid() From dogs")[0][0]
    end
    self
    end
    
    def self.create(hash)
      dog = Dog.new(hash)
      dog.save
      dog
    end
    
    def self.new_from_db(row)
      dog = self.new(id: row[0], name: row[1], breed: row[2])
    end
    
    def self.find_by_id(id)
      sql = <<-SQL
      Select * From dogs Where id = ?
      SQL
      DB[:conn].execute(sql, id).map do |row|
        self.new(id: row[0], name: row[1], breed: row[2])
      end.first
    end
    
    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("Select * From dogs Where name = ? And breed = ?", name, breed)
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data [0], name: dog_data [1], breed: dog_data [2])
      else
        dog = self.create(name: name, breed: breed)
      end
    dog
    end
    
    def self.find_by_name(name)
      sql = <<-SQL
      Select * From dogs Where name = ?
      SQL
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
    end
    
    def update
      sql = <<-SQL
      Update dogs Set name = ?, breed = ? Where id =?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  
end