extends Node3D

var selectedCommand:int
var pickedCommand:int = -1
var menuStage:int

@export var commandHeaders:Array[Node3D]
@export var menuCommands:Array[Node3D]
@export var tacticsCommands:Array[Node3D]
@export var cantripCommands:Array[Node3D]
@export var spellCommands:Array[Node3D]
@export var backButton:Node3D

@export var scrollTime:float

@onready var combat_circle: Node3D = $CombatCircle

func _ready():
	EventBus.connect("TargetBattle",TargetCommand)
	#DO THIS NEXT


func _input(event):
	if pickedCommand != -1:
		if event.is_action_pressed("LeftMouse"):
			print("Selecting!")
			SelectChoice(pickedCommand, menuStage)
			


func TargetCommand(selected:bool, choice:int=-1, stage:int=-1):
	#print("Signal")
	#prints("Command:", choice, "Menu Stage:", stage)
	var target:Node3D
	if stage != menuStage:
		pass
		#print("How did you select this? It's not even showing.")
	match stage:
		#-1: target = menuCommands[choice]
		0: target = menuCommands[choice]
		1: target = tacticsCommands[choice]
		2: target = cantripCommands[choice]
		3: target = spellCommands[choice]
		4: target = backButton
	var scaleTween = get_tree().create_tween()
	var scaleTween2 = get_tree().create_tween()
	if selected == false:
		if pickedCommand != -1:
			scaleTween.tween_property(target, "scale", Vector3(1,1,1), scrollTime)
			target.get_child(0).hide()
		pickedCommand = -1
		#print("No Choice")
		return
	if pickedCommand != -1:
		match menuStage:
			0: target = menuCommands[pickedCommand]
			1: target = tacticsCommands[pickedCommand]
			2: target = cantripCommands[pickedCommand]
			3: target = spellCommands[pickedCommand]
			4: target = backButton
		scaleTween.tween_property(target, "scale", Vector3(1,1,1), scrollTime)
		target.get_child(0).hide()
		return
	scaleTween2.tween_property(target, "scale", Vector3(1.2,1.2,1.2), scrollTime)
	target.get_child(0).show()
	pickedCommand = choice


func SelectChoice(choice:int, stage:int):
	prints("Command:", choice, "Menu Stage:", stage)
	if choice == 4:
		backButton.get_child(1).get_child(0).disabled = true
		await combat_circle.Turn(true)
		menuStage = 0
		commandHeaders[1].hide()
		commandHeaders[2].hide()
		commandHeaders[3].hide()
		return
	match stage:
		0: match choice:
			0:
				commandHeaders[1].show()
				await combat_circle.Turn(false)
				menuStage = 1
				backButton.get_child(1).get_child(0).disabled = false
			1:
				commandHeaders[2].show()
				await combat_circle.Turn(false)
				menuStage = 2
				backButton.get_child(1).get_child(0).disabled = false
			2:
				commandHeaders[3].show()
				await combat_circle.Turn(false)
				menuStage = 3
				backButton.get_child(1).get_child(0).disabled = false
		1: match choice:
			0: pass
			1: pass
			2: pass
		2: match choice:
			0: pass
			1: pass
			2: pass
		3: match choice:
			0: pass
			1: pass
			2: pass
		
	
	#if choice == 2:
		#await combat_circle.Turn(false)
		#menuStage = 3
		#backButton.get_child(1).get_child(0).disabled = false
