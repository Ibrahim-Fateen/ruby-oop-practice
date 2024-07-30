# frozen_string_literal: true

require_relative 'game_engine'

class GameControl
  def greet
    puts 'Welcome to Chessss!'
    puts "Enter 'new' to start a new game or 'load' to load a saved game."
    get_command
  end

  private

  def get_command
    command = gets.chomp.downcase
    case command
    when 'new'
      start_new
    when 'load'
      load_game
    else
      puts 'Invalid command. Please try again.'
      get_command
    end
  end

  def load_game
    # game_engine = GameEngine.new
    # get moves file
    # load moves to game engine and play
  end

  def start_new
    GameEngine.new.play
  end
end

GameControl.new.greet
