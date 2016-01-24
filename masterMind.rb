# draw board
# have computer generate random sequence
# have player guess color
# have computer give feedback
# give them 12 turn
# quit until player has won or turns are no more

module Board

	def draw_new_board
		most_recent_row = most_recently_placed_row
		@board.each_with_index do |hole, index|
			# feedback is dots and the xs next to the row
			@feedback = []
			print hole == 0 ? '|  O  |' : "|  #{hole}  |"
			if ((index +1) % 4).zero?
				feedback = 
					get_feed_back_given_index(index)
				prints_feed_back
				puts
			end
		end
	end

	def get_feed_back_given_index(index)
		color_array = []
		for colors in (index-3..index)
			color_array.push(@board[colors])
		end
		have_computer_give_feedback(color_array) unless color_array.include?(0)
	end

	def most_recently_placed_row
		@board_rows[@turns] + 3 if @turns <= 11
	end

	def prints_feed_back
		unless @feedback.nil?
			@feedback.each do |x_or_dot|
				print x_or_dot unless x_or_dot == 0
			end
		end
	end

	def have_computer_give_feedback(player_colors)
		computer_dup, player_dup = 
			collect_all_x(player_colors)
		@game_over = true if player_dup.size.zero?
		intersect = player_dup & computer_dup
		intersect.each {@feedback.push('.')}
		@feedback
	end

	# this function is meant to prevent dots
	# being counted twice in the give_feedback
	# functions
	def collect_all_x(player_colors)
		computer_dup = []
		player_dup = []
		player_colors.each_with_index do |color, index|
			if @hidden_sequence[index] == player_colors[index]
				@feedback.push('x')
			else
				computer_dup.push(@hidden_sequence[index])
				player_dup.push(player_colors[index])
			end
		end
		return computer_dup, player_dup
	end

end


module Computer

	def get_random_code
		random_sequence = [0, 0, 0, 0]
		random_sequence.each_with_index do |color, index|
			random_sequence[index] = rand(0..5)
		end
		converts_sequence_to_colors(random_sequence)
	end

	def converts_sequence_to_colors(random_sequence)
		# 'w' = white 'p' = purple 'y' = yellow 'g' = green
		# 'r' = red 'b' = blue
		@color_array = ['w', 'p', 'y', 'g', 'r', 'b']
		random_sequence.map { |rand_num| @color_array[rand_num] }
	end

	def chooses_based_on_feedback
		@feedback = []
		@feedback = get_feed_back_given_index(@board_rows[@turns])
		get_new_chosen_colors unless @feedback.nil?
	end

	def get_new_chosen_colors
		# this array decides what indexes of the color
		# array correspond to the x
		@new_color_array = [0] * 4
		@x_index_array = []
		symbol = 'x'
		@x_index_array = randomly_choose(@x_index_array, symbol)

		@dot_index_array = []
		symbol = '.'
		@dot_index_array = randomly_choose(@dot_index_array, symbol)
		convert_to_new_color_array

		# this method is necessary since the when the board
		# gives us back dots it means we have the right
		# colors we just have to swap them to a different
		# position
		@new_color_array = swap_dots
	  add_blanks_as_random_colors
		@new_color_array
	end

	def randomly_choose(index_array, symbol)
		x_or_dot_count = 0
		x_or_dot_count = @feedback.count(symbol)
		while index_array.size < x_or_dot_count
			random_index = rand(0..3)
			index_is_taken = is_taken?(index_array, random_index)
			index_array.push(random_index) unless index_is_taken
		end
		index_array
	end

	def is_taken?(index_array, random_index)
		if index_array.include?(random_index)
			return true
		elsif @x_index_array.size.zero?
			return false
		elsif @x_index_array.include?(random_index)
			return true
		else 
			false
		end
	end

	def convert_to_new_color_array
		combined_arrays = @x_index_array + @dot_index_array
		combined_arrays.each do |index|
			@new_color_array[index] = @chosen_colors[index]
		end
	end


	def swap_dots
		swapped_array = make_swapped_array
		@new_color_array.each_with_index do |color, index|
			if @dot_index_array.include?(index)
				random_index = rand(0..3)
				while !is_valid_index(random_index, index, swapped_array)
					random_index = rand(0..3)
				end
				swapped_array[random_index] = @chosen_colors[index]
			end
		end
		swapped_array
	end


	def make_swapped_array
		swapped_array = []
		for index in (0..3)
			if @x_index_array.include?(index)
				swapped_array.push(@chosen_colors[index])
			else swapped_array.push(0)
			end
		end
		swapped_array
	end

	def is_valid_index(random_index, index, swapped_array)
		if @x_index_array.include?(random_index)
			return false
		elsif random_index == index
			return false
		elsif swapped_array[random_index] != 0
			return false
		else true
		end
	end

	def add_blanks_as_random_colors
		while true
			@new_color_array.each_with_index do |color, index|
				if @new_color_array[index] == 0
					@new_color_array[index] = @color_array[rand(0..5)]
				end
			end
			break if does_not_equal_previous_row
		end
		@chosen_colors = @new_color_array
	end

	def does_not_equal_previous_row
		for index in (@board_rows[@turns]-3..@board_rows[@turns])
			if @new_color_array[index] != @board[index]
				return true
			end
		end
		false
	end

end

class MasterMind

	include Board, Computer

	def initialize
		@board = [0, 0, 0, 0] *12
		@feedback = []
		@color_array = ['w', 'p', 'y', 'g', 'r', 'b']
		@turns = 0
		@board_rows = [47, 43, 39, 35, 31, 27, 23, 19, 15, 11, 7, 3, 0]
		@game_over = false
		@code_maker = false
	end

	def play_game
		puts
		draw_new_board
		player_wants_to_break_code ? player_game : computer_game
	end

	def player_wants_to_break_code
		puts
		puts "Would you like to be the code breaker? (y/n)"
		answer = gets.chomp
		while (answer != 'y' && answer != 'n')
			puts "Would you like to be the code breaker? (y/n)"
			answer = gets.chomp
		end
		return answer == 'y' ? true : false
		puts
	end

	def player_game
		@hidden_sequence = get_random_code
		draw_instructions
		while (!is_game_over)
			have_player_guess_color
			draw_new_board
		end
		displays_end_for_player_game
	end

	def computer_game
		puts
		draw_color_code
		have_player_give_code
		@chosen_colors = get_random_code
		while true
			push_colors_to_the_board
			draw_new_board
			break if is_game_over
			chooses_based_on_feedback
			prints_thinking_screen
			sleep(0.2)
			@turns += 1
		end
		displays_end_for_computer_game
	end

	def have_player_give_code
		puts "Provide your secret code..."
		@hidden_sequence = gets.chomp.split(' ')
		while colors_not_valid(@hidden_sequence)
			puts "Provide your secret code..."
			@hidden_sequence = gets.chomp.split(' ')
		end
	end

	def prints_thinking_screen
		puts
		puts "Didn't quite get it. Tyring again!"
		puts
	end

	def did_the_player_win
		return true if @board[0] == 0
		return true if board_is_full_but_top_is_correct
		false
	end

	def board_is_full_but_top_is_correct
		return true if @board[0..3] == @hidden_sequence
	end

	def displays_end_for_computer_game
		puts
		puts "With your code #{@hidden_sequence.join(' ')}"
		if did_the_player_win
			puts "...the Computer cracked your code!"
		else puts "...the Computer could not crack it!"
		end
		puts
	end

	def displays_end_for_player_game
		puts
		puts "Code was #{@hidden_sequence.join(' ')}"
		puts did_the_player_win ? "You Win!" : "You Lose!"
		puts
	end

	def is_game_over
		return true unless @board.include?(0) && !@game_over 
		false
	end

	def draw_color_code
		puts
		puts 'Color Code: '
		puts 'w = white, p = purple, y = yellow'
		puts 'g = green, r = red, b = blue'
		puts
	end

	def draw_instructions
		puts
		puts 'Give your guess by placing your color guess'
		puts 'seperated by a space like so...'
		puts 'r r y g'
		draw_color_code
		puts 'Enter cc to draw up the color code.'
		puts
		puts 'The computer will place . next to the column'
		puts 'if your guess is the right color but wrong hole.'
		puts 'The comptuer will place x for right color and right'
		puts 'hole...'
	end

	def have_player_guess_color
		puts
		puts 'Place your guess...'
		@chosen_colors = gets.chomp.split(' ')
		draw_color_code if @chosen_colors == ['cc']
		while colors_not_valid(@chosen_colors)
			puts "Place your guess..."
			@chosen_colors = gets.chomp.split(' ')
		end
		@turns += 1
		puts
		push_colors_to_the_board
	end

	def get_bottom_row_index
		# this if statement means the board is not
		# blank
		if @board[47] != 0
			(@board.index {|hole| hole != 0}).to_i-4
		else
			# 44 is the index of the left side
			# of the bottom row
			44
		end
	end

	def push_colors_to_the_board
		index_start = get_bottom_row_index
		index_end = index_start + 3
		for index in (index_start..index_end)
			@board[index] = @chosen_colors[index - index_start]
		end
	end

	def colors_not_valid(colors)
		# returns false here since you have to have
		# 4 colors inputted
		return true if colors.length != 4
		colors.each do |color|
			return true unless @color_array.include?(color)
		end
		false
	end

end

game = MasterMind.new
game.play_game
