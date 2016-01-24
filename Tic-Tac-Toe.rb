module Turn

	def is_winning_move(board, current_turn)
		# combinations to win the game
		combos = [
			[0, 1, 2], [0, 3, 6], [0, 4, 8],
			[2, 5, 8], [3, 4, 5], [6, 7, 8],
			[1, 4, 7], [2, 4, 6]
		]

		combos.each do |combo|
			return true if is_winning_combo(combo, board, current_turn)
		end
		false
	end

	def is_winning_combo(combo, board, current_turn)
		combo.each do |row|
			return false if board[row] != current_turn
		end
		true
	end

	def is_board_full(board)
		# zero is a place holder for an empty space
		return true unless board.include?(0)
		false
	end

end	

class Board

	include Turn

	attr_accessor :board, :current_turn

	def initialize(board=[0]*9, current_turn=1)
		@board = board
		@current_turn = current_turn
	end

	def draw_board
		puts "-" * 21
		board.each_with_index do |row, index|
			draws_each_row(row, index)
		end
		puts "-" * 21
	end

	def draws_each_row(row, index)
		if row == 1
				print "|  X  |" 
		elsif row == 2
				print "|  O  |"
		else
				print "|  #{index +1}  |"
		end
		puts "\n" if ((index +1) % 3).zero?
	end

	def is_game_over
		# must flip turn since it changes within
		# the loop in play_game
		opposing_turn = current_turn == 1 ? 2 : 1
		if is_winning_move(board, opposing_turn) ||
			is_board_full(board)
			true
		else false
		end
	end

end

def play_game
	game = Board.new
	while !game.is_game_over
		game.draw_board
		current_turn, board, placement = get_user_input(game)
		board[placement-1] = current_turn
		current_turn = current_turn == 1 ? 2 : 1
		game = Board.new(board, current_turn)
	end
	game.draw_board
	draws_game_over(game)
end

def get_user_input(game)
	puts "Choose a number between 1 and 9..."
	placement = gets.chomp.to_i
	while !is_legal_placement(placement, game)
		puts "Please give a valid input..."
		placement = gets.chomp.to_i
	end
	return game.current_turn, game.board, placement
end

def is_legal_placement(placement, game)
	return true if placement >= 1 && placement <= 9 && 
	game.board[placement-1].zero?
	false
end

def draws_game_over(game)
	current_turn = game.current_turn
	# swap since current turn switches within
	# the loop at play_game
	current_turn = current_turn == 1 ? 2 : 1
	board_full = game.is_board_full(game.board)
	winner = game.is_winning_move(current_turn, game.board)
	if board_full && !winner
		puts "Tie Game!"
	else
		puts current_turn == 1 ? "X Won!" : "O Won!"
	end
end

play_game()