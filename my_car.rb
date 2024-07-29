# frozen_string_literal: true

class Vehicle
  @@number_of_vehicles = 0

  def self.number_of_vehicles
    puts "This program has created #{@@number_of_vehicles} vehicles."
  end

  def self.gas_mileage(gallons, miles)
    puts "#{miles / gallons} miles per gallon of gas"
  end

  def initialize
    @@number_of_vehicles += 1
  end
end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4

  def self.gas_mileage(gallons, miles)
    puts "#{miles / gallons} miles per gallon of gas"
  end

  attr_reader :year
  attr_accessor :color

  include DRIVEABLE

  def initialize(year, color, model)
    super()
    @year = year
    @color = color
    @model = model
  end

  def spray_paint(color)
    self.color = color
    puts "Your new #{color} paint job looks great!"
  end

  def to_s
    "My car is a #{color} #{year} #{@model}"
  end
end

class MyTruck < Vehicle
  NUMBER_OF_DOORS = 2

  include DRIVEABLE
end

module DRIVEABLE
  def drive
    puts "I'm driving!"
  end
end

my_car = MyCar.new(2010, 'silver', 'Ford Focus')
my_car.speed_up(20)
my_car.brake(10)
my_car.shut_off
my_car.spray_paint('red')
puts my_car.color
puts my_car.year
puts my_car

puts MyCar.ancestors
