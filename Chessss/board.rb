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

  def simulate_move(piece, target_position, all_pieces)
    original_position = piece.position
    captured_piece = all_pieces.find { |p| p.position == target_position && !p.is_dead }
    piece.move(target_position, all_pieces)
    captured_piece&.kill

    king_in_check = king_in_check?(piece.color, all_pieces)

    piece.move(original_position, all_pieces)
    captured_piece&.revive

    king_in_check
  end

  def king_in_check?(color, all_pieces)
    king = all_pieces.find { |p| p.is_a?(King) && p.color == color && !p.is_dead }
    opponent_pieces = all_pieces.select { |p| p.color != color && !p.is_dead }
    opponent_pieces.any? { |p| p.attacks?(king.position, all_pieces) }
  end
end
