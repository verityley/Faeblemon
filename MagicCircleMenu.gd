extends Node3D
class_name RingMenu

#class_name Commands
#Contains the actions and methods for basic UI option flow
#Also contains current state of turn, and sends signals to board state on UI selection
@export var ringMesh:MeshInstance3D
@export var skillDisplay:Node
@export var optionDistance:float = 1.333
@export var rotationTime:float = 2
@export var selectedIndex:int
var compassIndex:Array[int] = [0,1,2,3]
var currentState
enum States {
Reset = -1,
Start,
Familiar,
Attack,
Move,
Witch,
Party,
Spells,
End,
TurnCycle
}
var rotating:bool

@export var menuState:String = "Start" #Start, Wait, Witch, Familiar, Hide
@export var battleManager:BattleManager
@export var selectedBattler:Battler
@export var menuOffset:Vector3
var menuHidden:bool
var selectedState:String
var selectedSkill:Skill
var hideState:String
var optionSelected:Node3D
var witchChosen:bool
var familiarChosen:bool
var moveTaken:bool
var attackTaken:bool

@export var emptyDisplay:CompressedTexture2D
@export var tempAttack:Skill #extremely TEMPORARY

# Called when the node enters the scene tree for the first time.
func _ready():
	if ringMesh == null:
		ringMesh = $RingMesh
	MenuAction(States.Start)
	pass

func _input(event):
	#print(event)
	#if event.is_action_pressed("Cancel"):
		#if menuState == "Hide":
			#MenuFlow("Show")
			#print("Showing Menu")
		#else:
			#MenuFlow("Hide")
			#print("Hiding Menu")
	
	#if event.is_action_pressed("RightMouse") and !menuHidden:
		#if menuState != "Reset"  and menuState != "Start":
			#if menuState == "Witch" and !witchChosen:
				##MenuFlow("Start")
				#pass
			#elif menuState == "Familiar" and !familiarChosen:
				##MenuFlow("Start")
				#pass
	
	if optionSelected != null:
		if event.is_action_pressed("Confirm") or event.is_action_pressed("LeftMouse"):
			if rotating:
				return
			
			await RotateToTop(selectedIndex)
			#CompassReorder(selectedIndex)
			if currentState == States.Attack:
				CompassReorder(selectedIndex)
			else:
				ResetCircle()
			print("Current State: ", currentState, " Selected Option: ", selectedIndex)
			MenuFlow(selectedIndex)
			#MenuFlow(selectedState)
			#selectedState = ""

func RotateCircle(degrees:float): 
	var ringTween = get_tree().create_tween()
	var northTween = get_tree().create_tween()
	var eastTween = get_tree().create_tween()
	var southTween = get_tree().create_tween()
	var westTween = get_tree().create_tween()
	rotating = true
	
	var amount:float = deg_to_rad(degrees)
	var time:float = rotationTime / (360 / abs(degrees))
	var rotation = Vector3(0,0,amount) + ringMesh.rotation
	
	ringTween.tween_property(ringMesh, "rotation", rotation, time+0.02)
	northTween.tween_property(ringMesh.get_child(0), "rotation", -rotation, time)
	eastTween.tween_property(ringMesh.get_child(1), "rotation", -rotation, time)
	southTween.tween_property(ringMesh.get_child(2), "rotation", -rotation, time)
	westTween.tween_property(ringMesh.get_child(3), "rotation", -rotation, time)
	
	await northTween.finished
	#print("north finished")
	await eastTween.finished
	#print("east finished")
	await southTween.finished
	#print("south finished")
	await westTween.finished
	#print("west finished")
	await ringTween.finished
	#print("center finished")
	
	rotating = false
	return true

func ResetCircle():
	#await get_tree().create_timer(rotationTime+0.03)
	var index = 0
	
	for i in range(compassIndex.size()):
		compassIndex[i] = index
		if index >= 3:
			index = 0
		else:
			index += 1
	
	ringMesh.rotation = Vector3(0,0,0)
	for ring in ringMesh.get_children():
		ring.rotation_degrees = Vector3(0,0,0)

func RotateToTop(index:int): #clockwise positions, starting 0 at noon
	var target = compassIndex.find(index)
	#prints(target, index)
	
	if target == 0:
		return true
	elif target == 1:
		await RotateCircle(90)
	elif target == 2:
		await RotateCircle(180)
	elif target == 3:
		await RotateCircle(-90)
	return true

func CompassReorder(currentNorth:int):
	var index = currentNorth
	
	for i in range(compassIndex.size()):
		compassIndex[i] = index
		if index >= 3:
			index = 0
		else:
			index += 1
	
	#print(compassIndex)

func MenuAction(state:int):
	match state:
		States.Reset:
			print("Resetting Ring Menu")
			selectedState = ""
			selectedIndex = -1
			currentState = States.Start
			witchChosen = false
			familiarChosen = false
			moveTaken = false
			attackTaken = false
			selectedSkill = null
			if optionSelected != null:
				optionSelected.scale = Vector3(1,1,1)
				optionSelected = null
			MenuAction(States.Start)
		
		States.Start:
			print("Circle Menu: Start")
			for child in ringMesh.get_children():
				child.show()
				child.get_child(1).frame_coords.y = 0
				child.get_child(0).show()
				child.get_child(1).show()
				child.get_child(2).hide() #Hide Skill Option sprites
				child.get_child(3).hide()
				#child.get_child(2).frame_coords.y = 0
			skillDisplay.hide()
			selectedSkill = null
			MenuAction(States.Familiar)
			
			#ringMesh.get_child(0).hide()
			#currentState = States.Start
		
		States.Familiar:
			print("Circle Menu: Familiar")
			var index:int = 0
			for child in ringMesh.get_children():
				child.show()
				child.get_child(1).frame_coords = Vector2i(index, 1)
				child.get_child(1).show()
				child.get_child(2).hide() #Hide Skill Option sprites
				index += 1
			skillDisplay.hide()
			selectedSkill = null
			if attackTaken and selectedBattler.movepoints <= 0:
				MenuAction(States.End)
			
			if attackTaken:
				ringMesh.get_child(1).hide()
			else:
				ringMesh.get_child(1).show()
			if moveTaken and selectedBattler.movepoints <= 0:
				ringMesh.get_child(3).hide() #eventually replace with greyed out unclickable option
			else:
				ringMesh.get_child(3).show()
			if moveTaken or attackTaken:
				ringMesh.get_child(0).hide()
			else:
				ringMesh.get_child(0).show()
			currentState = States.Familiar
		
		States.Attack:
			print("Circle Menu: Attack")
			if selectedSkill != null:
				#Still TO DO:
				#Highlight energy cost on status box
				#Fade out display when turning
				skillDisplay.texture = selectedSkill.moveDisplay
				#battleManager.CheckAttackRange(selectedBattler, selectedSkill)
				battleManager.currentSkill = selectedSkill
				selectedSkill.Target(battleManager, selectedBattler)
				battleManager.ChangeBoardState("Attacking")
				return
			
			var index:int = 0
			for child in ringMesh.get_children():
				child.show()
				child.get_child(1).hide()
				child.get_child(2).show()
				var currentMove:Skill = selectedBattler.faebleEntry.assignedSkills[index-1]
				if currentMove != null:
					child.get_child(2).texture = (
					currentMove.movePreview)
					if selectedBattler.currentEnergy < currentMove.skillCost:
						print("Not enough energy for ", currentMove.skillName)
						child.get_child(2).modulate = Color(0.8,0.8,0.8,0.8)
						child.get_child(0).hide()
					else:
						child.get_child(2).modulate = Color(1,1,1,1)
						child.get_child(0).show()
				else:
					#child.get_child(2).hide()
					if index != 0:
						child.hide()
				index += 1
			skillDisplay.texture = emptyDisplay
			ringMesh.get_child(0).get_child(1).frame_coords = Vector2i(1, 0)
			ringMesh.get_child(0).get_child(1).show() #Revert back button to shown
			ringMesh.get_child(0).get_child(2).hide()
			skillDisplay.show()
			#battleManager.CheckAttackRange(selectedBattler, tempAttack)
			#battleManager.currentSkill = tempAttack #Replace with selected move
			#tempAttack.Target(battleManager, selectedBattler)
			#battleManager.ChangeBoardState("Attacking")
			currentState = States.Attack
		
		States.Move:
			print("Circle Menu: Move")
			for child in ringMesh.get_children():
				child.hide()
			ringMesh.get_child(0).get_child(1).frame_coords = Vector2i(1, 0)
			ringMesh.get_child(0).show()
			battleManager.CheckMoves(selectedBattler) #TEMPORARY
			battleManager.ChangeBoardState("Moving")
			print(battleManager.boardState)
			currentState = States.Move
		
		States.Witch:
			print("Circle Menu: Witch")
			for child in ringMesh.get_children():
				child.show()
				child.get_child(1).frame_coords.y = 2
				#child.get_child(2).frame_coords.y = 2
			
			if moveTaken: #or selectedBattler.movepoints <= 0:
				ringMesh.get_child(1).hide() #eventually replace with greyed out unclickable option
			else:
				ringMesh.get_child(1).show()
			if attackTaken:
				ringMesh.get_child(3).hide()
			else:
				ringMesh.get_child(3).show()
			if witchChosen:
				ringMesh.get_child(0).hide()
			else:
				ringMesh.get_child(0).show()
			currentState = States.Witch
		
		States.Party:
			print("Circle Menu: Party")
			for child in ringMesh.get_children():
				child.hide()
			ringMesh.get_child(0).show()
			currentState = States.Party
		
		States.Spells:
			print("Circle Menu: Spells")
			for child in ringMesh.get_children():
				child.hide()
			ringMesh.get_child(0).show()
			currentState = States.Spells
		
		States.End:
			print("Circle Menu: End")
			for child in ringMesh.get_children():
				child.hide()
			currentState = States.End
			battleManager.ProgressTurn()
			#TO DO
			#Also put in the turn order display stuff here! To showcase change of turn
		
		States.TurnCycle:
			print("Circle Menu: Turn Cycle")
			var turnOrder:Array[Battler] = battleManager.roundOrder.duplicate()
			if turnOrder.size() >= 3:
				var lastBattler = turnOrder.pop_back()
				turnOrder.push_front(battleManager.currentBattler)
				turnOrder.push_front(lastBattler)
			else:
				turnOrder.push_front(battleManager.currentBattler)
				turnOrder.push_front(null)
			print(turnOrder)
			var index:int = 0
			for child in ringMesh.get_children():
				child.show()
				for sprite in child.get_children():
					sprite.hide()
					print("Hiding Sprite: ", sprite)
				child.get_child(3).show()
				print(child.get_child(3))
				if turnOrder[index] != null:
					child.get_child(3).texture = turnOrder[index].faebleEntry.UISprite
					print(index, ": ", turnOrder[index].faebleEntry.name)
				else:
					child.get_child(3).texture = null
				index += 1
				if index >= turnOrder.size():
					break
			await get_tree().create_timer(0.15).timeout
			#print("Does it get to here? 1")
			await RotateToTop(1)
			battleManager.currentBattler.get_child(1).show()
			battleManager.currentBattler.statusBox.get_child(7).show()
			#print("Does it get to here? 2")
			await get_tree().create_timer(1.0).timeout
			#print("Does it get to here? 3")
			ResetCircle()
			currentState = States.TurnCycle
			#print("Does it get to here? 4")
			MenuAction(States.Reset)

func MenuFlow(option:int):
	match currentState:
		States.Start:
			match option:
				0:
					pass
				1:
					MenuAction(States.Familiar)
				2:
					MenuAction(States.End)
				3:
					MenuAction(States.Witch)
		
		States.Familiar:
			match option:
				0:
					MenuAction(States.Witch)
				1:
					MenuAction(States.Attack)
				2:
					MenuAction(States.End)
				3:
					MenuAction(States.Move)
		
		States.Move:
			match option:
				0:
					MenuAction(States.Familiar)
					battleManager.CleanBoardState()
		
		States.Attack:
			match option:
				0:
					selectedSkill = null
					MenuAction(States.Familiar)
					battleManager.CleanBoardState()
				1:
					battleManager.CleanBoardState()
					selectedSkill = selectedBattler.faebleEntry.assignedSkills[0]
					MenuAction(States.Attack)
				2:
					battleManager.CleanBoardState()
					selectedSkill = selectedBattler.faebleEntry.assignedSkills[1]
					MenuAction(States.Attack)
				3:
					battleManager.CleanBoardState()
					selectedSkill = selectedBattler.faebleEntry.assignedSkills[2]
					MenuAction(States.Attack)
		
		States.Witch:
			match option:
				0:
					MenuAction(States.Familiar)
				1:
					MenuAction(States.Party)
				2:
					MenuAction(States.Party) #Replace eventually
				3:
					MenuAction(States.Spells)
		
		States.Party:
			match option:
				0:
					MenuAction(States.Witch)
		
		States.Spells:
			match option:
				0:
					MenuAction(States.Witch)
		

#func OldMenuFlow(state):
	#if state == "Reset": #Use this to clear all variable values, end of turn(?)
		##HideMenu(true, false)
		##if selectedBattler != null:
			##position = selectedBattler.position + menuOffset
		#selectedState = ""
		#witchChosen = false
		#familiarChosen = false
		#moveTaken = false
		#attackTaken = false
		#if optionSelected != null:
			#optionSelected.scale = Vector3(1,1,1)
			#optionSelected = null
		#MenuFlow("Start")
	#
	#if state == "Hide": #Temporarily hide, but remember last menu
		#HideMenu(true)
		#menuState = "Hide"
	#if state == "Show": #Reveal from hidden, onto last menu
		#HideMenu(false)
	#
	#if state == "Start": #Fresh state, show topmost available options
		##show()
		##position = selectedBattler.position + menuOffset
		##for button in get_children():
		##	button.hide()
		##$EndTurn.show()
		#if witchChosen:
			#state = "Witch"
		#elif familiarChosen:
			#state = "Familiar"
		#else:
			##$Familiar.show()
			##$Witch.show()
			#menuState = "Start"
	#
	#if state == "EndTurn":
		#battleManager.ProgressTurn()
		#MenuFlow("Reset")
	#
	#if state == "Familiar": #Familiar acting, show move and attack
		#for child in ringMesh.get_children():
			#child.get_child(1).frame_coords.y = 1
			#child.get_child(2).frame_coords.y = 1
		#
		#if moveTaken: #or selectedBattler.movepoints <= 0:
			#ringMesh.get_child(1).hide() #eventually replace with greyed out unclickable option
		#else:
			#ringMesh.get_child(1).show()
		#if attackTaken:
			#ringMesh.get_child(3).hide()
		#else:
			#ringMesh.get_child(3).show()
		#if familiarChosen:
			#ringMesh.get_child(0).hide()
		#else:
			#ringMesh.get_child(0).show()
		#currentState = States.Familiar
	#
	#if state == "Move": #Familiar moving, show movement grid and move points
		##for button in get_children():
			##button.hide()
		#HideMenu(true, true)
		#battleManager.CheckMoves(selectedBattler) #TEMPORARY
		#battleManager.ChangeBoardState("Moving")
		#print(battleManager.boardState)
		#menuState = "Move"
		#pass
	#
	#if state == "Attack": #Familiar attacking, show attack options, mana, and ranges
		##for button in get_children():
			##button.hide()
		#HideMenu(true, true)
		##battleManager.CheckAttackRange(selectedBattler, tempAttack)
		#battleManager.currentSkill = tempAttack
		#tempAttack.Target(battleManager, selectedBattler)
		#battleManager.ChangeBoardState("Attacking")
		#menuState = "Attack"
		#pass
	#
	#
	#if state == "Witch": #Witch selected, show tactics and spells
		#for button in get_children():
			#button.hide()
		#$EndTurn.show()
		#if !moveTaken:
			#$Tactics.show()
		#if !attackTaken:
			#$Spell.show()
		#menuState = "Witch"
	#
	#if state == "Tactics": #Show tactics options
		#for button in get_children():
			#button.hide()
		#menuState = "Tactics"
		#pass
	#
	#if state == "Spell": #Show spell list
		#for button in get_children():
			#button.hide()
		#menuState = "Spell"
		#pass
#
#func HideMenu(hide:bool, recall:bool=true):
	#if selectedBattler != null:
		#position = selectedBattler.position + menuOffset
	#if hide:
		#menuHidden = true
		#if recall:
			#hideState = menuState
		#else:
			#hideState = ""
		#for button in get_children():
			#button.hide()
	#else:
		#menuHidden = false
		#if recall and hideState != null:
			#MenuFlow(hideState)
		#else:
			#MenuFlow("Start")

func SelectMenu(index:int, exit=false):
	if exit: #If exited or canceled, revert scale and value
		if optionSelected != null:
			optionSelected.scale = Vector3(1,1,1)
		optionSelected = null
		selectedState = ""
		return
	if rotating:
		return
	#print(str(self) + "/" + state) #Find child by name, from self
	optionSelected = ringMesh.get_child(index)
	optionSelected.scale = Vector3(1.1,1.1,1.1) #Replace with tween effect eventually
	selectedIndex = index

func ChangeTarget():
	pass
