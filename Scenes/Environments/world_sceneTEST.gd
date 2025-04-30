extends Node3D

@export var stageSystem:StageSystem
@export var battleSystem:BattleSystem
@onready var stageResource = preload("res://Scenes/Environments/World Scenes/Forest/Resources/SparseForest.tres")

func _ready():
	await stageSystem.LoadScene(stageResource, 1)
	battleSystem.BattleSetup(stageSystem)
	battleSystem.ChangeBattler(FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),4), true)
	battleSystem.ChangeBattler(FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),4), false)
	
