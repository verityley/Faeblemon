extends Node3D
class_name CommandsManager

@export var battleSystem:BattleSystem

var selectedMana:int
var pickedMana:int = -1

var selectedCommand:int
var pickedCommand:int = -1
var menuStage:int

var selecting:bool #true while selection input is resolving

@export var commandHeaders:Array[Node3D]
@export var menuCommands:Array[Node3D]
@export var tacticsCommands:Array[Node3D]
@export var cantripCommands:Array[Node3D]
@export var spellCommands:Array[Node3D]
@export var backButton:Node3D
@export var manaSelectors:Array[Node3D]

@export var scrollTime:float
@export var turnTime:float

@export var CircleMenu:Node3D

func _ready():
	EventBus.connect("TargetBattle",TargetCommand)
	EventBus.connect("TargetMana",TargetMana)


func _input(event):
	if pickedCommand != -1:
		if event.is_action_pressed("LeftMouse"):
			print("Selecting!")
			SelectChoice(pickedCommand, menuStage)
	if pickedMana != -1:
		if event.is_action_pressed("LeftMouse"):
			print("Selecting Mana!")
			SelectMana(pickedMana)

func ResetCommandMenu():
	match selectedMana:
		1: TurnMana(true)
		2: TurnMana(false)
	menuStage = 0
	selectedCommand = 0
	selectedMana = 0
	pickedCommand = -1
	pickedMana = -1
	manaSelectors[0].get_child(0).get_child(0).disabled = false
	manaSelectors[1].get_child(0).get_child(0).disabled = false
	manaSelectors[2].get_child(0).get_child(0).disabled = false
	backButton.get_child(1).get_child(0).disabled = true
	selecting = false
	await TurnCommands(true)
	commandHeaders[1].hide()
	commandHeaders[2].hide()
	commandHeaders[3].hide()
	#TEMP

func FillOptions(faeblePool:Array[Skill], witchPool:Array[Skill]):
	for i in range(faeblePool.size()):
		if faeblePool[i] == null:
			spellCommands[i].hide()
		else:
			var texture:Material
			texture = spellCommands[i].get_surface_override_material(0)
			texture.albedo_texture = faeblePool[i].moveDisplay
			spellCommands[i].set_surface_override_material(0, texture)
			spellCommands[i].show()
	
	for i in range(witchPool.size()):
		if witchPool[i] == null:
			cantripCommands[i].hide()
		else:
			var texture:Material
			texture = cantripCommands[i].get_surface_override_material(0)
			texture.albedo_texture = witchPool[i].moveDisplay
			cantripCommands[i].set_surface_override_material(0, texture)
			cantripCommands[i].show()

func TargetMana(selected:bool, choice:int=-1):
	if selecting:
		print("Can't target while selection in process.")
		if pickedMana != -1:
			var scaleTween = get_tree().create_tween()
			scaleTween.tween_property(manaSelectors[choice], "scale", Vector3(0.8,0.8,0.8), scrollTime)
			pickedMana = -1
		return
	#print("Signal")
	#prints("Command:", choice, "Menu Stage:", stage)
	if choice == -1:
		print("Something went wrong! Invalid choice target!")
		return
	var target:Node3D = manaSelectors[choice]
	var scaleTween = get_tree().create_tween()
	var scaleTween2 = get_tree().create_tween()
	if selected == false:
		if pickedMana != -1:
			scaleTween.tween_property(target, "scale", Vector3(0.8,0.8,0.8), scrollTime)
		pickedMana = -1
		#print("No Choice")
		return
	if pickedMana != -1:
		scaleTween.tween_property(target, "scale", Vector3(0.8,0.8,0.8), scrollTime)
		return
	scaleTween2.tween_property(target, "scale", Vector3(1,1,1), scrollTime)
	pickedMana = choice


func TargetCommand(selected:bool, choice:int=-1, stage:int=-1):
	if selecting:
		print("Can't target while selection in process.")
		var target:Node3D
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
		return
	#print("Signal")
	#prints("Command:", choice, "Menu Stage:", stage)
	if choice == -1:
		print("Something went wrong! Invalid choice target!")
		return
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

func SelectMana(choice:int):
	if choice == selectedMana:
		print("No change needed.")
		return
	selecting = true
	match selectedMana:
		0: 
			if choice == 1: await TurnMana(false)
			else: await TurnMana(true)
		1: 
			if choice == 2: await TurnMana(false)
			else: await TurnMana(true)
		2: 
			if choice == 0: await TurnMana(false)
			else: await TurnMana(true)
	selectedMana = choice
	selecting = false


func SelectChoice(choice:int, stage:int):
	prints("Command:", choice, "Menu Stage:", stage)
	selecting = true
	if choice == 4:
		backButton.get_child(1).get_child(0).disabled = true
		await TurnCommands(true)
		menuStage = 0
		commandHeaders[1].hide()
		commandHeaders[2].hide()
		commandHeaders[3].hide()
		selecting = false
		manaSelectors[0].get_child(0).get_child(0).disabled = false
		manaSelectors[1].get_child(0).get_child(0).disabled = false
		manaSelectors[2].get_child(0).get_child(0).disabled = false
		return
	if stage == 0:
		commandHeaders[choice+1].show()
		manaSelectors[0].get_child(0).get_child(0).disabled = true
		manaSelectors[1].get_child(0).get_child(0).disabled = true
		manaSelectors[2].get_child(0).get_child(0).disabled = true
		await TurnCommands(false)
		menuStage = choice+1
		backButton.get_child(1).get_child(0).disabled = false
		selecting = false
		return
	else:
		battleSystem.AwaitInput(true, choice, stage)
		
	
	#if choice == 2:
		#await combat_circle.Turn(false)
		#menuStage = 3
		#backButton.get_child(1).get_child(0).disabled = false

func TurnCommands(main:bool):
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var back:Node3D = CircleMenu.get_child(1)
	var commands:Node3D = CircleMenu.get_child(2)
	if main:
		tween.tween_property(back, "rotation", Vector3(0,0,deg_to_rad(0)), turnTime)
		tween2.tween_property(commands, "rotation", Vector3(0,0,deg_to_rad(0)), turnTime)
	else:
		tween.tween_property(back, "rotation", Vector3(0,0,deg_to_rad(180)), turnTime)
		tween2.tween_property(commands, "rotation", Vector3(0,0,deg_to_rad(180)), turnTime)
	await tween.finished

func TurnMana(clockwise:bool):
	print("Turning Mana!")
	var tween = get_tree().create_tween()
	var manaWheel:Node3D = CircleMenu.get_child(1).get_child(0)
	var target:Vector3
	if clockwise:
		target = manaWheel.rotation - Vector3(0,0,deg_to_rad(120))
		tween.tween_property(manaWheel, "rotation", target, turnTime/2)
	else:
		target = manaWheel.rotation + Vector3(0,0,deg_to_rad(120))
		tween.tween_property(manaWheel, "rotation", target, turnTime/2)
	await tween.finished
