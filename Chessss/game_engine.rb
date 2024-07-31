# frozen_string_literal: true

require_relative 'board'
require_relative 'player'

class GameEngine
  def initialize(file_name = nil)
    @board = Board.new
    @players = [Player.new('white'), Player.new('black')]
    @current_player = @players[0]
    @opponent = @players[1]
    @game_over = false
    @history = []
    return unless file_name

    File.open(file_name, 'r').each do |line|
      move = line.scan(/\[\d, \d\]/)
      make_move(move)
      switch_players
    end
  end

  def play
    until @game_over
      display_game
      begin
        move(move_from_user)
        if check?
          puts 'Check!'
          sleep(2)
        end
      rescue InvalidMoveException => e
        print e.message
        puts ' Please try again. '
        retry
      rescue HelpException
        display_help
        retry
      rescue SaveException
        begin
          save_game
        rescue Errno::ENONET
          puts 'Invalid file name. Please try again.'
          sleep(1)
          retry
        end
        next
      rescue QuitException
        @game_over = true
        break
      end
      if checkmate?(@opponent.color)
        checkmate(@current_player.color)
        break
      end
      if stalemate?(@opponent.color)
        stalemate
        break
      end
      switch_players
    end
  end

  def make_move(line)
    initial = line[0].scan(/\d/).map(&:to_i)
    final = line[1].scan(/\d/).map(&:to_i)
    move([initial, final])
  end

  private

  def display_game
    system('clear') || system('cls')
    puts 'At any time, enter "help" for a list of commands.'
    @board.display_board(@players.map(&:pieces).flatten)
    puts "It's #{@current_player.color}'s turn."
  end

  def move(move)
    initial, final = move
    selected_piece = @current_player.pieces.find { |piece| piece.position == initial && !piece.is_dead }
    raise InvalidMoveException, 'No piece selected.' unless selected_piece
    raise InvalidMoveException, 'Not your piece.' unless selected_piece.color == @current_player.color

    all_pieces = @players.map(&:pieces).flatten
    return if selected_piece.is_a?(Pawn) && en_passant?(selected_piece, final)
    return if selected_piece.is_a?(King) && castle?(selected_piece, initial, final)

    raise InvalidMoveException, 'Not supported.' unless selected_piece.valid_move?(final, all_pieces)
    raise InvalidMoveException, 'King is in Check.' if @board.check_after_move?(selected_piece, final, all_pieces)

    @history << [selected_piece.dup, initial, final]
    selected_piece.move(final, all_pieces)
    return unless selected_piece.is_a?(Pawn) && (selected_piece.position[0].zero? || selected_piece.position[0] == 7)

    @current_player.pieces << selected_piece.promote
  end

  def checkmate(color)
    puts 'Checkmate!'
    puts "Congratulations, #{color} wins!"
    @game_over = true
  end

  def stalemate
    puts 'Stalemate!'
    puts 'It\'s a draw!'
    @game_over = true
  end

  def move_from_user
    print 'Enter the move you want to make (e.g. a2 a4):'
    move = gets.chomp.downcase
    raise HelpException if move.downcase == 'help'
    raise SaveException if move.downcase == 'save'
    raise QuitException if move.downcase == 'exit'
    raise InvalidMoveException, "Doesn't match pattern." unless move.match?(/[a-h][1-8] [a-h][1-8]/)

    move.split(' ').map { |position| [8 - position[1].to_i, position[0].ord - 97] }
  end

  def en_passant?(selected_piece, final)
    last_enemy_move = @history.last
    return false unless last_enemy_move && last_enemy_move[0].is_a?(Pawn)

    pass_position = selected_piece.color == 'white' ? 3 : 4
    base_position = selected_piece.color == 'white' ? 1 : 6
    if selected_piece.position[0] == pass_position && (final[0] == pass_position + 1 || final[0] == pass_position - 1)
      if last_enemy_move[2][0] == pass_position && last_enemy_move[1][0] == base_position
        if last_enemy_move[2][1] == final[1]
          @opponent.pieces.find { |piece| !piece.is_dead && piece.position == last_enemy_move[2] }&.kill
          selected_piece.move(final, @players.map(&:pieces).flatten)
          puts 'En passant!'
          sleep(2)
          return true
        end
      end
    end
    false
  end

  def castle?(selected_piece, king_position, rook_position)
    return false unless selected_piece.is_a?(King) && !selected_piece.has_moved

    rook = @current_player.pieces.find { |piece| piece.position == rook_position && !piece.is_dead }
    return false unless rook.is_a?(Rook)
    raise InvalidMoveException, 'Can\'t castle, Rook has already moved.' if rook.has_moved

    direction = rook_position[1] > king_position[1] ? 1 : -1
    (1..2).each do |i|
      if @board.king_in_check?(@current_player.color, @players.map(&:pieces).flatten)
        raise InvalidMoveException, 'Can\'t castle, King is in check.'
      end
      return false if @board.king_in_check?(@opponent.color, @players.map(&:pieces).flatten)

      new_position = [king_position[0], king_position[1] + i * direction]
      if @players.map(&:pieces).flatten.any? { |piece| piece.position == new_position && !piece.is_dead }
        raise InvalidMoveException, 'Can\'t castle, path is blocked.'
      end

      if @board.check_after_move?(selected_piece, new_position, @players.map(&:pieces).flatten)
        raise InvalidMoveException, 'Can\'t castle, path is checked.'
      end
    end

    selected_piece.move([king_position[0], king_position[1] + 2 * direction], @players.map(&:pieces).flatten)
    rook.move([rook_position[0], king_position[1] + direction], @players.map(&:pieces).flatten)
    @history << [selected_piece.dup, king_position, rook.position]
    puts 'Castle!'
    sleep(2)
    true
  end

  def display_help
    puts 'Commands:'
    puts 'Enter "save" to save the game.'
    puts 'Enter "exit" to quit the game.'
    puts
  end

  def valid_input?(position)
    return false unless position.length == 2 && position[0].between?('a', 'h') && position[1].between?('1', '8')

    true
  end

  def switch_players
    @current_player, @opponent = @opponent, @current_player
  end

  def check?
    opponent_king = @opponent.pieces.find { |piece| piece.is_a?(King) && !piece.is_dead }
    @current_player.attacks?(opponent_king.position, @players.map(&:pieces).flatten)
  end

  def checkmate?(color)
    no_legal_moves?(color) && @board.king_in_check?(color, all_pieces)
  end

  def stalemate?(color)
    no_legal_moves?(color) && !@board.king_in_check?(color, all_pieces)
  end

  def no_legal_moves?(color)
    all_pieces = @players.map(&:pieces).flatten
    current_player_pieces = all_pieces.select { |p| p.color == color && !p.is_dead }
    current_player_pieces.all? do |piece|
      piece.valid_moves(all_pieces).all? do |move|
        @board.check_after_move?(piece, move, all_pieces)
      end
    end
  end

  def save_game
    system('clear') || system('cls')
    puts 'Enter the name of the file you want to save the game to:'
    file_name = gets.chomp

    File.open(file_name, 'w') do |file|
      @history.each do |move|
        file.puts move.map(&:to_s).join(' ')
      end
    end
    puts 'Game saved!'
    sleep(1)
    puts 'Press Enter to continue...'
    gets
  end
end

class HelpException < StandardError; end

class QuitException < StandardError; end

class SaveException < StandardError; end

class InvalidMoveException < StandardError; end
