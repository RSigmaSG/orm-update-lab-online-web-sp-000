require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id = nil, name, grade)

    @name = name
    @id = id
    @grade = grade

  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      #binding.pry
      DB[:conn].execute(sql,self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid()
      FROM students")[0][0]
    end
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
    SQL
 
    DB[:conn].execute(sql).map.each {|row|puts "row : #{row}"}

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the 
    new_student = self.new(row[0], row[1],row[2])  # self.new is the same as running Song.new
    new_student
  end


  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
      #puts self
    end.first
    #binding.pry
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(nil, name, grade)
    student.save
    student
  end

end
