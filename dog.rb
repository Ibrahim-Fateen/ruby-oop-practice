# frozen_string_literal: true

class Dog
  def initialize(name)
    @name = name
  end

  def bark
    'Ruff! Ruff!'
  end
end

bobby = Dog.new('Bobby')
puts bobby.bark

class Insect
  def initialize(age_in_days)
    @age_in_days = age_in_days
  end

  def age_in_years
    @age_in_days / 365.0
  end
end

class WaterBottle
  def initialize(capacity)
    @capacity = capacity
  end

  def capacity
    @capacity
  end
end

class Person
  attr_reader :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

module MathHelpers
  def exponent(base, power)
    base**power
  end
end

class Calculator
  include MathHelpers

  def square_root(number)
    exponent(number, 0.5)
  end
end
