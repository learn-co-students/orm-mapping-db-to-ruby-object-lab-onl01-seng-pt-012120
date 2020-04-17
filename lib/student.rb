require 'pry'

class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    student = self.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    sql = 'SELECT * FROM students'
    rows = DB[:conn].execute(sql)
    rows.map{|row| self.new_from_db(row)}
  end

  def self.find_by_name(name)
    sql = 'SELECT * FROM students WHERE name = ?'
    name_found = DB[:conn].execute(sql, name)

    self.all.select{|student| student.name == name_found[0][1]}[0]
  end

  def self.all_students_in_grade_9
    self.all.select{|student| student.grade == '9'}.to_a
  end

  def self.students_below_12th_grade
    self.all.select{|student| student.grade < '12'}.to_a
  end

  def self.first_X_students_in_grade_10(x)
    self.all.select{|student| student.grade == '10'}[0..x-1]
  end

  def self.first_student_in_grade_10
     self.first_X_students_in_grade_10(1)[0]
  end

  def self.all_students_in_grade_X(x)
     self.all.select{|student| student.grade == x}.to_a
     binding.pry
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
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
end
