# frozen_string_literal: true

class ChessPiece
  TOP_RIGHT = [-1, 1].freeze
  TOP_LEFT = [-1, -1].freeze
  BOTTOM_RIGHT = [1, 1].freeze
  BOTTOM_LEFT = [1, -1].freeze
  UP = [-1, 0].freeze
  DOWN = [1, 0].freeze
  RIGHT = [0, 1].freeze
  LEFT = [0, -1].freeze

  attr_reader :symbol, :position, :color, :is_dead

  def initialize(color, position)
    @color = color
    @position = position
    @has_moved = false
    @is_dead = false
  end

  def attacks?(target_position, all_pieces)
    sees?(target_position, all_pieces, attack_vectors)
  end

  def valid_move?(target_position, all_pieces)
    vectors = if all_pieces.any? do |piece|
      piece.position == target_position && !piece.is_dead && piece.color != @color
    end
                attack_vectors
              else
                move_vectors
              end
    if is_a?(Pawn) && !has_moved
      sees?(target_position, all_pieces, vectors, 2)
    else
      sees?(target_position, all_pieces, vectors)
    end
  end

  def move(target_position, all_pieces)
    all_pieces.find { |piece| piece.position == target_position }&.kill

    @position = target_position
    @has_moved = true
  end

  def kill
    @is_dead = true
  end

  protected

  attr_reader :has_moved

  private

  attr_reader :move_vectors, :attack_vectors, :max_displacement
  attr_writer :has_moved, :is_dead, :position

  def sees?(target_position, all_pieces, sight_vectors, max_displacement = @max_displacement)
    return false if target_position == @position
    return false if all_pieces.any? do |piece|
      !piece.is_dead && piece.position == target_position && piece.color == @color
    end

    sight_vectors.each do |vector|
      (1..max_displacement).each do |i|
        new_position = [@position[0] + i * vector[0], @position[1] + i * vector[1]]
        return true if new_position == target_position
        break if new_position[0] > 7 || new_position[1] > 7 || new_position[0].negative? || new_position[1].negative?
        break if all_pieces.any? { |piece| !piece.is_dead && piece.position == new_position }
      end
    end
    false
  end
end

class King < ChessPiece
  def initialize(color, position)
    super
    @symbol = color == 'white' ? '♔' : '♚'
    @move_vectors = [TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT, UP, DOWN, RIGHT, LEFT]
    @attack_vectors = @move_vectors
    @max_displacement = 1
  end
end

class Queen < ChessPiece
  def initialize(color, position)
    super
    @symbol = color == 'white' ? '♕' : '♛'
    @move_vectors = [TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT, UP, DOWN, RIGHT, LEFT]
    @attack_vectors = @move_vectors
    @max_displacement = 1000
  end
end

class Rook < ChessPiece
  def initialize(color, position)
    super
    @symbol = color == 'white' ? '♖' : '♜'
    @move_vectors = [UP, DOWN, RIGHT, LEFT]
    @attack_vectors = @move_vectors
    @max_displacement = 1000
  end
end

class Bishop < ChessPiece
  def initialize(color, position)
    super
    @symbol = color == 'white' ? '♗' : '♝'
    @move_vectors = [TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT]
    @attack_vectors = @move_vectors
    @max_displacement = 1000
  end
end

class Knight < ChessPiece
  def initialize(color, position)
    super
    @symbol = color == 'white' ? '♘' : '♞'
    @move_vectors = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]
    @attack_vectors = @move_vectors
    @max_displacement = 1
  end
end

class Pawn < ChessPiece
  def initialize(color, position)
    super
    @symbol = color == 'white' ? '♙' : '♟'
    @move_vectors = color == 'white' ? [UP] : [DOWN]
    @attack_vectors = color == 'white' ? [TOP_RIGHT, TOP_LEFT] : [BOTTOM_RIGHT, BOTTOM_LEFT]
    @max_displacement = 1
  end

  def promote
    @is_dead = true
    puts 'Promote to:'
    puts '1. Queen'
    puts '2. Rook'
    puts '3. Bishop'
    puts '4. Knight'
    print '> '
    choice = gets.chomp.to_i
    case choice
    when 1
      Queen.new(@color, @position)
    when 2
      Rook.new(@color, @position)
    when 3
      Bishop.new(@color, @position)
    when 4
      Knight.new(@color, @position)
    else
      puts 'Invalid choice. Promoting to Queen.'
      Queen.new(@color, @position)
    end
  end
end
