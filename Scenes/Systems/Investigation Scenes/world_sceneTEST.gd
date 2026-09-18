extends Node3D

@export var stageSystem:StageSystem
@onready var stageResource = preload("res://Scenes/Environments/World Scenes/Forest/Resources/SparseForest.tres")
@export var witch1:Witch
@export var witch2:Witch

func _ready():
	await stageSystem.LoadScene(stageResource, 1)
	EventBus.connect("FaebleMoved",ChangeRange)
	await get_tree().create_timer(0.5).timeout
	ChangeRange(Enums.Ranges.Far)
	await get_tree().create_timer(1.5).timeout
	ChangeRange(Enums.Ranges.Near)
	await get_tree().create_timer(1.5).timeout
	ChangeRange(Enums.Ranges.Melee)
	await get_tree().create_timer(1.5).timeout
	ChangeRange(Enums.Ranges.Near)
	await get_tree().create_timer(1.5).timeout
	ChangeRange(Enums.Ranges.Far)
	await get_tree().create_timer(1.5).timeout
	ChangeRange(Enums.Ranges.Melee)
	#battleSystem.DisplayCommands(false)
	#var spawn1:Faeble = FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),19)
	#var spawn2:Faeble = FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),19)
	#battleSystem.BattleStart(spawn1,spawn2,witch1,witch2)

func ChangeRange(range:Enums.Ranges):
	match range:
		Enums.Ranges.Melee:
			stageSystem.LayerHide(5,true)
			await stageSystem.LayerHide(6,true, true)
		Enums.Ranges.Near:
			stageSystem.LayerHide(5,true)
			await stageSystem.LayerHide(6,false, true)
		Enums.Ranges.Far:
			stageSystem.LayerHide(5,false)
			await stageSystem.LayerHide(6,false, true)
