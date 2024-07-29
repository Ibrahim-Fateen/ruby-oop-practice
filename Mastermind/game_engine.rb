require_relative 'guesser'

class GameEngine
  CODEMAKER = '1'.freeze
  CODEBREAKER = '2'.freeze
  EASY = '1'.freeze
  HARD = '2'.freeze

  def initialize
    @code = []
    @guesses = []
    @feedback = []
    @mode = nil
    @difficulty = EASY
    @guesser = nil
  end

  def play
    greet
    if @mode == CODEMAKER
      @guesser = Guesser.new
      play_as_codemaker
    else
      play_as_codebreaker
    end
  end

  private

  def greet
    puts 'Welcome to Mastermind!'
    choose_mode
  end

  def choose_mode
    puts 'Would you like to play as the Codemaker or the Codebreaker?'
    puts 'Enter "1" for Codemaker or "2" for Codebreaker.'
    @mode = gets.chomp
    until %w[1 2].include?(@mode)
      puts 'Invalid input. Please enter "1" for Codemaker or "2" for Codebreaker.'
      @mode = gets.chomp
    end
    return unless @mode == CODEBREAKER

    choose_difficulty

  end

  def choose_difficulty
    puts 'Choose a difficulty level: (level affects the feedback you receive)'
    puts 'Enter "1" for Easy or "2" for Hard.'
    @difficulty = gets.chomp
    until %w[1 2].include?(@difficulty)
      puts 'Invalid input. Please enter "1" for Easy or "2" for Hard.'
      @difficulty = gets.chomp
    end
  end

  def play_as_codemaker
    init_codemaker
    display
    gets
    12.times do |i|
      guess = @guesser.make_guess(@feedback.last, @guesses.last)
      # guess = @guesser.make_guess('+ + + +', [1, 2, 1, 1])
      feedback = generate_feedback(guess)
      @guesses << guess
      display
      if feedback == '+ + + + '
        puts 'The Codebreaker has cracked the code!'
        break
      end
      gets
    end
  end

  def init_codemaker
    puts 'You are the Codemaker. Set a code consisting of 4 numbers between 1 and 6.'
    puts 'The Codebreaker will have 12 guesses to crack it.'
    puts 'Press Enter to continue.'
    gets
    4.times do
      print 'Enter a number between 1 and 6: '
      num = gets.chomp.to_i
      until (1..6).cover?(num)
        puts 'Invalid input. Please enter a number between 1 and 6.'
        num = gets.chomp.to_i
      end
      @code << num
    end
    puts "The code has been set to #{@code}. Press Enter to continue."
    gets
  end

  def play_as_codebreaker
    init_codebreaker
    display
    12.times do |i|
      guess = gets.chomp.split.map(&:to_i)
      until guess.size == 4 && guess.all? { |num| (1..6).cover?(num) }
        puts 'Invalid input. Please enter 4 numbers between 1 and 6 separated by spaces.'
        guess = gets.chomp.split.map(&:to_i)
      end
      feedback = generate_feedback(guess)
      @guesses << guess
      display
      if feedback == '+ + + + '
        puts 'Congratulations! You have cracked the code!'
        break
      elsif i == 11
        puts 'You have run out of guesses. The code was:'
        @code.each { |num| print "#{num} " }
        puts
        break
      end

      sleep(1)
    end
  end

  def init_codebreaker
    4.times { @code << rand(1..6) }
    puts 'The Codemaker has set a code. The code consists of 4 numbers between 1 and 6.'
    puts 'You have 12 guesses to crack it. Each guess should be entered as 4 numbers separated by spaces.'
    sleep(2)
  end

  def display
    system('clear') || system('cls')
    display_header
    display_body
  end

  def display_body
    12.times do |i|
      print "Guess ##{i + 1}: "
      if @guesses[i]
        @guesses[i].each { |num| print "#{num} " }
      else
        4.times { print '- ' }
      end
      puts
      puts "Feedback: #{@feedback[i] || 'No feedback yet'}"
      puts
    end
    print 'Enter your guess: ' if @mode == CODEBREAKER
    print 'Press Enter for next computer guess.' if @mode == CODEMAKER
  end

  def display_header
    puts '--------------------'
    puts '        Mastermind'
    puts '--------------------'
    if @mode == CODEMAKER
      puts '         Codemaker'
      print 'Code:    '
      @code.each { |num| print "#{num} " }
      puts
    else
      puts 'Codebreaker'
      puts 'Code:    X-X-X-X'
    end
    puts '--------------------'
    return unless @difficulty == EASY

    puts 'Feedback: + means a correct number in the correct position, - means a correct number in the wrong position, and / means a wrong number.'
    puts '--------------------'
  end

  def generate_feedback(guess)
    feedback = ''
    code_dup = @code.dup
    correct_pos = 0
    correct_num = 0

    # First pass: Check for correct positions
    guess.each_with_index do |num, i|
      if code_dup[i] == num
        correct_pos += 1
        correct_num += 1
        code_dup[i] = nil # Mark this position as matched
        feedback << '+ '
      end

      # Second pass: Check for correct numbers in wrong positions
      next if @code[i] == num # Skip already matched positions

      if code_dup.include?(num)
        correct_num += 1
        code_dup[code_dup.index(num)] = nil # Mark this number as matched
        feedback << '- '
      else
        feedback << '/ '
      end
    end

    hard_feedback_message = "You have #{correct_num} correct numbers with #{correct_pos} of them in the correct positions."
    @feedback << (@difficulty == EASY ? feedback : hard_feedback_message)
    feedback
  end
end

GameEngine.new.play
