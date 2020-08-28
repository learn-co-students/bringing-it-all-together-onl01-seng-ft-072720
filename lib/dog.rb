class Dog
    attr_accessor :name, :breed, :id

    #    has a name and a breed has an id that defaults to `nil` on initialization accepts key value pairs as arguments to initialize

    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
        self.id ||= nil
    end

    #   creates the dogs table in the database

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

    # drops the dogs table from the database

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs;
        SQL
        DB[:conn].execute(sql)
    end    

    #    returns an instance of the dog class saves an instance of the dog class to the database and then sets the given dogs `id` attribute

    def save
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end    

    #    takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database returns a new dog object

    def self.create(hash_of_attributes)
        dog = self.new(hash_of_attributes)
        dog.save
        dog
    end

    # creates an instance with corresponding attribute values

    def self.new_from_db(row)
        attributes_hash = {
          :id => row[0],
          :name => row[1],
          :breed => row[2]
        }
        self.new(attributes_hash)
      end

      # returns a new dog object by id

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end       

    #     creates an instance of a dog if it does not already exist when two dogs have the same name and different breed, it returns the correct dog when creating a new dog with the same name as persisted dogs, it returns the correct dog
    
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ? AND breed = ?
          SQL
    
    
          dog = DB[:conn].execute(sql, name, breed).first
    
          if dog
            new_dog = self.new_from_db(dog)
          else
            new_dog = self.create({:name => name, :breed => breed})
          end
          new_dog
      end  

      #  returns an instance of dog that matches the name from the DB

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
            end.first
    end    

    #  updates the record associated with a given instance

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? 
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end    
end
