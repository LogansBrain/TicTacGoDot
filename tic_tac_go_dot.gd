extends Node2D

# These are the 2 symbols in the game that can be chosen for players tokens.
const SYMBOL = ["X","O"]

@onready var buttons = $GridContainer.get_children()

var playersturn = true  # True if we are expecting user input. (including selecting token)
var computermoves = 0   # Number of moves the computer has made
var current_player = 0  # Current player (0 is first, 1 is second)
var player_token        # Which token the player has selected to play
var new_game_status = true  # If we are starting a new game, waiting for Token selection

# pattern is an array of strings 9 characters in length that represent the squares of a board
# the 3 '*' characters in each pattern represents a winning line with the 9 square board
var pattern: Array[String] = ["***------",
							 "---***---", 
							 "------***", 
							 "*--*--*--", 
							 "-*--*--*-",
							 "--*--*--*",
							 "*---*---*",
							 "--*-*-*--"] 

# new_game sets up the board and global variables to start a new game
# sets new_game_status to true to await input choice of player token
# disables all button controls on the page that should not function during this time
# changes the status text to indicate waiting for token choice
# sets the current player global variable to 0 (first player)
# sets playersturn to true to await a user input
# resets computers move count to 0

func new_game():
	var button_index = 0
	new_game_status = true
	$btnNewGame.disabled=true
	for button in buttons:
		if button_index==3:
			button.text = "X"
			button.disabled = false
		elif button_index==5:
			button.text = "O"
			button.disabled = false
		else:
			button.text = ""
			button.disabled = true
		button_index += 1
		
	$lblStatus.text = "Choose Token, X Goes First"
	current_player = 0
	playersturn = true
	computermoves = 0

# check_pattern checks the board for a winning pattern given the symbol passed
# blank counts blank spaces in a winning pattern
# matches counts number of matches in a winning pattern

func check_pattern(check_symbol):

	var blank
	var matches
	
	# for each pattern in our array
	for i in range(8):
		# initialize the count of blanks and matches
		blank=0
		matches=0
		# for each position in the string pattern
		for j in range(9):
			# check if the position of the board is matters to our winning pattern
			if pattern[i][j] == "*":
				# if the position is relevant check if it is occupied by the symbol we are checking
				if buttons[j].text == check_symbol:
					matches += 1
				# or if the relevant position is blank
				elif buttons[j].text == "":
					blank = j+1  # add one to be used in verify
		#if 2 marks from the same player and a blank are in the same line return that position
		if (matches == 2) and (blank > 0):
			return blank
	return 0  # otherwise return 0, no winning place found

# checkgameover checks the 8 possible winning lines to see if the same
# player (symbol) occupies all 3 positions and returns True
# or if the board is fully occupied it will also return True
# full tracks if the board is full
# matches tracks the number of matches within a winning pattern

func checkgameover(symbol):

	var full = true
	var matches = 0

	for i in range(8):  # 0-7 Number of (8) winning combos
		matches = 0
		for j in range(9): # 0-8 Number of (9) boxes
			if (pattern[i][j] == "*") and (buttons[j].text == symbol):
				matches += 1
				if matches == 3:
					$lblStatus.text = symbol+" WINS!"
					for button in buttons:
						button.disabled=true
					return true
	full = true
	for i in range(9):
		if buttons[i].text == "":
			full = false
	if full:
		$lblStatus.text = "Tie Game."
		for button in buttons:
			button.disabled=true
		return true

# the computer_move function determines a move for the computer.
# the place variable tracks the best place to go
# the done tracks if the search for place to go is done
# move tracks the square that is the move to be made
# try counts the number of tries the computer looks for a space to go

func computer_move():

	var place
	var done
	var move
	var try

	randomize()

	move = 0
	computermoves += 1

	# Check for possible winning move
	if move == 0:
		move = check_pattern(SYMBOL[player_token^1])

	# Check for a place to block
	if move == 0:
		move = check_pattern(SYMBOL[player_token])
		
	place = 0
	done = false
	try = 0
	while !done:
		# increase try count
		try += 1
		# if move is > 0 then we have found a move
		if move > 0:
			place = move - 1   # minus 1 because we use 0 to indicate no move
		else:
			if buttons[4].text == "":  # the computer will always try to take Center square
				place = 4
			else:
				# after the computers first 2 moves or if the 50 attempts to
				# take a preferred side or corner the computer will take a 
				# completely random choice
				if (computermoves > 2) or (try > 50):
					place = int(round(randi_range(0, 8)))
				else: 
					# this is the logic for the computers 2nd move
					# if the player is in the center the computer will prefer 
					# an even numbered square (corner)
					# technically the center is even also but the computer already
					# tried for their first move as center, it is taken by this point
					if buttons[4].text == SYMBOL[player_token]:
						place = int(round(randi_range(0, 4))) * 2
					else:
						# otherwise an odd (side) square
						place = int(round(randi_range(0, 4)) * 2) + 1
		# if the square that we have chosen is blank then put a mark there
		if buttons[place].text == "":
			done = true
			buttons[place].text = SYMBOL[player_token^1]
	# check if the computers move was a winning move or filled the board.
	checkgameover(SYMBOL[player_token^1])
	playersturn=true
	
func _ready():
	var button_index = 0
	$btnNewGame.connect("pressed", on_btnNewGame_click.bind())
	for button in buttons:
		button.connect("pressed", on_btnSquare_click.bind(button_index, button))
		button_index += 1
	new_game()

func on_btnSquare_click(idx, clicked_button):
	# when a player clicks the board,check if it is users turn.
	if not playersturn:
		return
		
	# if the new_game_status flag is set, draw a board to allow token choice	
	if new_game_status:
		if idx==3:
			player_token=0
		else:
			player_token=1
		for button in buttons:
			button.text=""
			button.disabled=false
		new_game_status=false
		$btnNewGame.disabled=false
		if player_token==1:
			computer_move()
		return
	
	# if it is the player turn and they have already selected a token
	# check if the square selected is taken, if not give it to player
	# check if the players move created a win or tie if not move the computer	
	if clicked_button.text=="":
		clicked_button.text = SYMBOL[player_token]
		playersturn=false
		if !checkgameover(SYMBOL[player_token]):
			computer_move()
		
func on_btnNewGame_click():
	new_game()
