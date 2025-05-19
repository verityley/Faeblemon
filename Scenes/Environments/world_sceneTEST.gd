extends Node3D

@export var stageSystem:StageSystem
@export var battleSystem:BattleSystem
@onready var stageResource = preload("res://Scenes/Environments/World Scenes/Forest/Resources/SparseForest.tres")
@export var witch1:Witch
@export var witch2:Witch

func _ready():
	await stageSystem.LoadScene(stageResource, 1)
	battleSystem.DisplayCommands(false)
	var spawn1:Faeble = FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),4)
	var spawn2:Faeble = FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),4)
	battleSystem.BattleStart(spawn1,spawn2,witch1,witch2)
