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
    sql = <<-SQL
      SELECT * FROM students
    SQL
    rows = DB[:conn].execute(sql)

    rows.map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    name_found = DB[:conn].execute(sql, name)

    self.all.map do |student|
      if student.name == name_found[0][1]
        return student
      end
    end
  end

  def self.all_students_in_grade_9
    students_with_grade_9 = []

    self.all.map do |student|
      if student.grade == '9'
        students_with_grade_9 << student
      end
    end
    return students_with_grade_9
  end

  def self.students_below_12th_grade
    self.all.select{|student| student.grade < '12'}.to_a
  end

  def self.first_X_students_in_grade_10(x)
    self.all.select{|student| student.grade == '10'}[0..x-1]
  end

=begin
  def self.first_student_in_grade_10
     self.first_X_students_in_grade_10(1)
     #binding.pry
  end
=end
  def self.all_students_in_grade_X(x)
     self.all.select{|student| student.grade == x}
     #binding.pry
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
