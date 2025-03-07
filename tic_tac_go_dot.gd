extends Node2D
#
const SYMBOL = ["X","O"]

@onready var buttons = $GridContainer.get_children()

var playersturn = true
var computermoves = 0
var current_player = 0
var player_token
var new_game_status = true
var pattern: Array[String] = ["***------",
							 "---***---", 
							 "------***", 
							 "*--*--*--", 
							 "-*--*--*-",
							 "--*--*--*",
							 "*---*---*",
							 "--*-*-*--"] 

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

func check_pattern(check_symbol):

	var blank
	var matches
	
	for i in range(8):
		blank=0
		matches=0
		for j in range(9):
			if pattern[i][j] == "*":
				if buttons[j].text == check_symbol:
					matches += 1
				elif buttons[j].text == "":
					blank = j+1  # add one to be used in verify
		if (matches == 2) and (blank > 0):
			return blank
	return 0

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
		try += 1
		if move > 0:
			place = move - 1
		else:
			if buttons[4].text == "":
				place = 4
			else:
				if (computermoves > 2) or (try > 20):
					place = int(round(randi_range(0, 8)))
				else: 
					if buttons[4].text == SYMBOL[player_token]:
						place = int(round(randi_range(0, 4))) * 2
					else:
						place = int(round(randi_range(0, 4)) * 2) + 1
		if buttons[place].text == "":
			done = true
			buttons[place].text = SYMBOL[player_token^1]
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
	if not playersturn:
		return
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
		
	if clicked_button.text=="":
		clicked_button.text = SYMBOL[player_token]
		playersturn=false
		if !checkgameover(SYMBOL[player_token]):
			computer_move()
		
func on_btnNewGame_click():
	new_game()
