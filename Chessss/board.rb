# frozen_string_literal: true

class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def display_board(pieces)
    puts '    a   b   c   d   e   f   g   h'
    puts '  +---+---+---+---+---+---+---+---+'
    @grid.each_with_index do |row, i|
      print "#{8 - i} |"
      row.each_with_index do |cell, j|
        piece = pieces.find { |p| p.position == [i, j] && !p.is_dead }
        print " #{piece.nil? ? ' ' : piece.symbol} |"
      end
      puts
      puts '  +---+---+---+---+---+---+---+---+'
    end
  end
end
