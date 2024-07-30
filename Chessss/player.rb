# frozen_string_literal: true

require_relative 'chess_piece'

class Player
  attr_reader :color, :pieces

  def initialize(color)
    @color = color
    base_position = color == 'white' ? 7 : 0
    pawns_position = color == 'white' ? 6 : 1
    @pieces = [
      Rook.new(color, [base_position, 0]), Knight.new(color, [base_position, 1]),
      Bishop.new(color, [base_position, 2]), Queen.new(color, [base_position, 3]),
      King.new(color, [base_position, 4]), Bishop.new(color, [base_position, 5]),
      Knight.new(color, [base_position, 6]), Rook.new(color, [base_position, 7])
    ]
    @pieces += 8.times.map { |i| Pawn.new(color, [pawns_position, i]) }
  end

  def attacks?(position, all_pieces)
    @pieces.each do |piece|
      next if piece.is_dead
      return true if piece.attacks?(position, all_pieces)
    end
    false
  end
end
