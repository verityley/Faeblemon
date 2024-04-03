extends Node3D
#Contains the actions and methods for basic UI option flow
#Also contains current state of turn, and sends signals to board state on UI selection
@export var menuState:String = "Start" #Start, Wait, Witch, Familiar, Hide
@export var battleManager:BattleManager
@export var selectedBattler:Battler #extremely TEMPORARY
@export var menuOffset:Vector3
var selectedState:String
var hideState:String
var optionSelected:Node3D
var witchChosen:bool
var familiarChosen:bool
var moveTaken:bool
var attackTaken:bool

@export var tempAttack:Skill

# Called when the node enters the scene tree for the first time.
func _ready():
	#MenuFlow(menuState)
	pass

func _input(event):
	#print(event)
	if event.is_action_pressed("Cancel"):
		if menuState == "Hide":
			MenuFlow("Show")
			print("Showing Menu")
		else:
			MenuFlow("Hide")
			print("Hiding Menu")
	
	if optionSelected != null:
		if event.is_action_pressed("Confirm") or event.is_action_pressed("LeftMouse"):
			MenuFlow(selectedState)
			selectedState = ""

func MenuFlow(state):
	position = selectedBattler.position + menuOffset
	if state == "Reset": #Use this to clear all variable values, end of turn(?)
		HideMenu(true, false)
		selectedState = ""
		witchChosen = false
		familiarChosen = false
		moveTaken = false
		attackTaken = false
		optionSelected.scale = Vector3(1,1,1)
		optionSelected = null
		menuState = "Start"
	if state == "Hide": #Temporarily hide, but remember last menu
		HideMenu(true)
		menuState = "Hide"
	if state == "Show": #Reveal from hidden, onto last menu
		HideMenu(false)
	
	if state == "Start": #Fresh state, show topmost available options
		for button in get_children():
			button.hide()
		if witchChosen:
			state = "Witch"
		elif familiarChosen:
			state = "Familiar"
		else:
			$Familiar.show()
			$Witch.show()
			menuState = "Start"
	
	
	if state == "Familiar": #Familiar acting, show move and attack
		for button in get_children():
			button.hide()
		familiarChosen = true
		if !moveTaken or selectedBattler.movepoints > 0:
			$Move.show() #eventually replace with greyed out unclickable option
		if !attackTaken:
			$Attack.show()
		menuState = "Familiar"
	
	if state == "Move": #Familiar moving, show movement grid and move points
		for button in get_children():
			button.hide()
		battleManager.CheckMoves(selectedBattler) #TEMPORARY
		battleManager.ChangeBoardState("Moving")
		print(battleManager.boardState)
		menuState = "Move"
		pass
	
	if state == "Attack": #Familiar attacking, show attack options, mana, and ranges
		for button in get_children():
			button.hide()
		battleManager.CheckAttackRange(selectedBattler, tempAttack)
		battleManager.ChangeBoardState("Attacking")
		menuState = "Attack"
		pass
	
	
	if state == "Witch": #Witch selected, show tactics and spells
		for button in get_children():
			button.hide()
		witchChosen = true
		if !moveTaken:
			$Tactics.show()
		if !attackTaken:
			$Spell.show()
		menuState = "Witch"
	
	if state == "Tactics": #Show tactics options
		for button in get_children():
			button.hide()
		menuState = "Tactics"
		pass
	
	if state == "Spell": #Show spell list
		for button in get_children():
			button.hide()
		menuState = "Spell"
		pass

func HideMenu(hide:bool, recall:bool=true):
	if hide:
		if recall:
			hideState = menuState
		else:
			hideState = ""
		for button in get_children():
			button.hide()
	else:
		if recall and hideState != null:
			MenuFlow(hideState)
		else:
			MenuFlow("Start")

func SelectMenu(state:String, exit=false):
	if exit: #If exited or canceled, revert scale and value
		optionSelected.scale = Vector3(1,1,1)
		optionSelected = null
		selectedState = ""
		return
	#print(str(self) + "/" + state) #Find child by name, from self
	optionSelected = get_node(str(get_path()) + "/" + state)
	optionSelected.scale += Vector3(0.2, 0.2, 0.2) #Replace with tween effect eventually
	selectedState = state

func ChangeTarget():
	pass
