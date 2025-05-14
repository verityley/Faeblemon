extends Node3D

@export var stageSystem:StageSystem
@export var battleSystem:BattleSystem
@onready var stageResource = preload("res://Scenes/Environments/World Scenes/Forest/Resources/SparseForest.tres")

func _ready():
	await stageSystem.LoadScene(stageResource, 1)
	battleSystem.BattleSetup(stageSystem)
	battleSystem.DisplayCommands(false)
	var spawn1:Faeble = FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),4)
	var spawn2:Faeble = FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),4)
	battleSystem.BattleStart(spawn1,spawn2,null,null)
