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
# Called when the node enters the scene tree the first time.

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
	
	print("Checking Pattern")
	for i in range(8):
		print("I is ",i," and Pattern I is: ",pattern[i])
		blank=0
		matches=0
		for j in range(9):
			if pattern[i][j] == "*":
				if buttons[j].text == check_symbol:
					matches += 1
				else:
					if buttons[j].text == "":
						blank = j

		if (matches == 2) and (blank > 0):
			return blank+1

	return 0


func checkgameover(symbol):

	var full = true
	var matches = 0

	print("Checking for GAME OVER conditions.")
	for i in range(8):  # 0-7 Number of (8) winning combos
		matches = 0
		for j in range(9): # 0-8 Number of (9) boxes
			#print("I:",i," J:",j)
			#print("P:",pattern[i]," C:",pattern[i][j]," B:", buttons[j].text," S:",symbol)
			if (pattern[i][j] == "*") and (buttons[j].text == symbol):
				matches += 1
				#print("Match @",j," Matches: ",matches)
				if matches == 3:
					$lblStatus.text = symbol+" WINS!"
					for button in buttons:
						button.disabled=true
					return true
	# If noone won the game, check if all squares are full
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

	print("Computer thinking...")
	randomize()

	move = 0
	computermoves += 1
	print("Computer Move Count: ", computermoves)

	# Check for possible winning move
	if move == 0:
		print("Checking for Win")
		move = check_pattern(SYMBOL[player_token^1])
		print(move)

	# Check for a place to block
	if move == 0:
		print("Checking for Block")
		move = check_pattern(SYMBOL[player_token])
		print(move)
		
	place = 0
	done = false
	try = 0
	while !done:
		try += 1
		print("Try: ",try, " Done: ",done)
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
						place = int(round(randi_range(0, 3)) * 2) + 1
		if buttons[place].text == "":
			done = true
			buttons[place].text = SYMBOL[player_token^1]
	if checkgameover(SYMBOL[player_token^1]):
		print("Game over.")
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
	#print("New Game Status = ", new_game_status)
	#print("Current Player #", current_player,", Symbol: ",SYMBOL[current_player])
	#print("Button Index: ", idx)
	if new_game_status:
		if idx==3:
			player_token=0
		else:
			player_token=1
		#print("Player Token: ",SYMBOL[player_token])
		#print("Computer Token: ",SYMBOL[player_token^1])
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
		if checkgameover(SYMBOL[player_token]):
			print("win detected")
		else:
			computer_move()
		

func on_btnNewGame_click():
	print("New Game Clicked")
	new_game()

		
