class Guesser
  def initialize
    @positions_left = [0, 1, 2, 3]
    @incorrect_numbers = []
  end

  def make_guess(last_feedback, last_guess)
    return [rand(1..6), rand(1..6), rand(1..6), rand(1..6)] if last_feedback.nil?

    last_feedback = last_feedback.split
    correct_pos = []
    incorrect_pos = []
    incorrect_num = []
    guess = Array.new(4)

    last_feedback.each_with_index do |feedback, index|
      case feedback
      when '+'
        correct_pos << index
      when '-'
        incorrect_pos << index
      when '/'
        incorrect_num << index
      end
    end

    incorrect_num.each { |pos| @incorrect_numbers << last_guess[pos] }

    correct_pos.each do |pos|
      guess[pos] = last_guess[pos]
      @positions_left.delete(pos)
    end

    positions_left = @positions_left.dup
    incorrect_pos.each do |pos|
      new_pos = positions_left.delete_at(rand(positions_left.size))
      guess[new_pos] = last_guess[pos]
    end

    positions_left.each do |pos|
      random = rand(1..6)
      random = rand(1..6) while @incorrect_numbers.include?(random)
      guess[pos] = random
    end

    guess
  end
end
