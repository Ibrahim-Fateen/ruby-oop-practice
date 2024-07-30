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
        move
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
      switch_players
    end
  end

  def make_move(move)
    initial = move[0].scan(/\d/).map(&:to_i)
    final = move[1].scan(/\d/).map(&:to_i)
    selected_piece = @current_player.pieces.find { |piece| piece.position == initial && !piece.is_dead }
    @history << [selected_piece.dup, initial, final]
    all_pieces = @players.map(&:pieces).flatten
    selected_piece.move(final, all_pieces)
    return unless selected_piece.is_a?(Pawn) && (selected_piece.position[0].zero? || selected_piece.position[0] == 7)

    @current_player.pieces << selected_piece.promote
  end

  private

  def display_game
    system('clear') || system('cls')
    puts 'At any time, enter "help" for a list of commands.'
    @board.display_board(@players.map(&:pieces).flatten)
    puts "It's #{@current_player.color}'s turn."
  end

  def move
    initial, final = move_from_user
    selected_piece = @current_player.pieces.find { |piece| piece.position == initial && !piece.is_dead }
    raise InvalidMoveException, 'No piece selected.' unless selected_piece
    raise InvalidMoveException, 'Not your piece.' unless selected_piece.color == @current_player.color

    all_pieces = @players.map(&:pieces).flatten
    return if selected_piece.is_a?(Pawn) && en_passant?(selected_piece, final)

    raise InvalidMoveException, 'Not supported' unless selected_piece.valid_move?(final, all_pieces)

    @history << [selected_piece.dup, initial, final]
    selected_piece.move(final, all_pieces)
    return unless selected_piece.is_a?(Pawn) && (selected_piece.position[0].zero? || selected_piece.position[0] == 7)

    @current_player.pieces << selected_piece.promote
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
