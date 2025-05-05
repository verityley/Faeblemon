extends Node3D

var selectedCommand:int
var pickedCommand:int = -1
var menuStage:int

@export var menuCommands:Array[Node3D]
@export var tacticsCommands:Array[Node3D]
@export var cantripCommands:Array[Node3D]
@export var spellCommands:Array[Node3D]

@export var scrollTime:float

@onready var combat_circle: Node3D = $CombatCircle

func _init():
	connect("TargetCommand", TargetCommand)
	#DO THIS NEXT


func _input(event):
	if pickedCommand != -1:
		if event.is_action_pressed("LeftMouse"):
			print("Selecting!")
			SelectChoice(pickedCommand, menuStage)
			


func TargetCommand(selected:bool, choice:int=-1, stage:int=-1):
	print("Signal")
	prints("Command:", choice, "Menu Stage:", stage)
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
	var scaleTween = get_tree().create_tween()
	var scaleTween2 = get_tree().create_tween()
	if selected == false:
		if pickedCommand != -1:
			scaleTween.tween_property(target, "scale", Vector3(1,1,1), scrollTime)
			target.get_child(0).hide()
		pickedCommand = -1
		print("No Choice")
		return
	if pickedCommand != -1:
		match menuStage:
			0: target = menuCommands[pickedCommand]
			1: target = tacticsCommands[pickedCommand]
			2: target = cantripCommands[pickedCommand]
			3: target = spellCommands[pickedCommand]
		scaleTween.tween_property(target, "scale", Vector3(1,1,1), scrollTime)
		target.get_child(0).hide()
		return
	scaleTween2.tween_property(target, "scale", Vector3(1.2,1.2,1.2), scrollTime)
	target.get_child(0).show()
	pickedCommand = choice


func SelectChoice(choice:int, stage:int):
	prints("Command:", choice, "Menu Stage:", stage)
	if choice == 2:
		combat_circle.Turn()
		menuStage = 3
