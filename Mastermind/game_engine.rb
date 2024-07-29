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
    @difficulty = nil
  end

  def play
    greet
    if @mode == CODEMAKER
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
    puts '         X-X-X-X'
    puts '--------------------'
    if @difficulty == EASY
      puts 'Feedback: + means a correct number in the correct position, - means a correct number in the wrong position, and / means a wrong number.'
      puts '--------------------'
    end
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
    print 'Enter your guess: '
  end

  def generate_feedback(guess)
    feedback = ''
    correct_num = 0
    correct_pos = 0
    guess.each_with_index do |num, i|
      correct_pos += 1 if @code[i] == num
      correct_num += 1 if @code.include?(num)
      feedback << if @code[i] == num
                    '+ '
                  elsif @code.include?(num)
                    '- '
                  else
                    '/ '
                  end
    end
    hard_feedback_message = "You have #{correct_num} correct numbers and #{correct_pos} correct positions."
    @feedback << (@difficulty == EASY ? feedback : hard_feedback_message)
    feedback
  end
end

GameEngine.new.play
