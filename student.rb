# frozen_string_literal: true

class Student
  attr_reader :name

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(other_student)
    grade > other_student.grade
  end

  protected

  attr_reader :grade
end

joe = Student.new('Joe', 90)
bob = Student.new('Bob', 84)
puts "Well done!" if joe.better_grade_than?(bob)

