# frozen_string_literal: true

class Grid
  def initialize
    @grid = Array.new(3) { Array.new(3, ' ') }
  end

  def display
    system('clear') || system('cls')
    puts '  0 1 2'
    @grid.each_with_index do |row, index|
      print "#{index} "
      puts row.join('|')
      puts '  -----' unless index == 2
    end
  end

  def update(row, column, symbol)
    raise InvalidMoveError if row.nil? || column.nil? || row.negative? || column.negative? || row > 2 || column > 2
    raise InvalidMoveError if @grid[row][column] != ' '

    @grid[row][column] = symbol
  end

  def full?
    @grid.all? { |row| row.none? { |cell| cell == ' ' } }
  end

  def won?(row, column, symbol)
    row_win?(row, symbol) || column_win?(column, symbol) || diagonal_win?(symbol)
  end

  private

  def row_win?(row, symbol)
    @grid[row].all? { |cell| cell == symbol }
  end

  def column_win?(column, symbol)
    @grid.all? { |row| row[column] == symbol }
  end

  def diagonal_win?(symbol)
    left_diagonal_win?(symbol) || right_diagonal_win?(symbol)
  end

  def left_diagonal_win?(symbol)
    (0..2).all? { |i| @grid[i][i] == symbol }
  end

  def right_diagonal_win?(symbol)
    (0..2).all? { |i| @grid[i][2 - i] == symbol }
  end
end

class InvalidMoveError < StandardError
end

class Winner < StandardError
end