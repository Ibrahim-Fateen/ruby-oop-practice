# frozen_string_literal: true
require_relative 'grid'
require_relative 'player'

class GameEngine
  def initialize
    @grid = Grid.new
    @players = [Player.new('Player 1', 'X'), Player.new('Player 2', 'O')]
    @current_player = @players[0]
  end

  def play
    greet_players
    puts 'Let the game begin!, Press Enter to continue...'
    _ = gets
    loop do
      @grid.display
      begin
        row, column = get_move
        @grid.update(row, column, @current_player.symbol)
        raise Winner if @grid.won?(row, column, @current_player.symbol)
      rescue InvalidMoveError
        puts 'Invalid move! Try again.'
        retry
      rescue Winner
        @grid.display
        puts "Congratulations! #{@current_player.name} wins!"
        sleep(4)
        break
      end

      break if @grid.full?

      switch_players
      sleep(1)
    end

    puts 'Game over!'
  end

  private

  def get_move
    puts "#{@current_player.name}, enter your move as: row column"
    gets.split.map(&:to_i)
  end

  def greet_players
    puts 'Welcome to Tic Tac Toe!'
    puts 'The grid is as follows:'
    puts 'row 0: 0|1|2'
    puts '       -----'
    puts 'row 1: 0|1|2'
    puts '       -----'
    puts 'row 2: 0|1|2'
  end

  def switch_players
    @current_player = @current_player == @players[0] ? @players[1] : @players[0]
  end
end

GameEngine.new.play
