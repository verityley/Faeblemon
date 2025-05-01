extends Node3D

@export var stageSystem:StageSystem
@export var battleSystem:BattleSystem
@onready var stageResource = preload("res://Scenes/Environments/World Scenes/Forest/Resources/SparseForest.tres")

func _ready():
	await stageSystem.LoadScene(stageResource, 1)
	battleSystem.BattleSetup(stageSystem)
	var spawn1:Faeble = FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),4)
	var spawn2:Faeble = FaebleCreation.CreateFaeble(stageResource.faebleGrabBag(),4)
	battleSystem.ChangeBattler(spawn1, true)
	battleSystem.ChangeBattler(spawn2, false)
	battleSystem.MaxHealthReset(spawn1.maxHP,true)
	battleSystem.MaxHealthReset(spawn2.maxHP,false)
	battleSystem.SetHealthDisplay(spawn1.maxHP, spawn1.maxHP/2,true)
	battleSystem.SetHealthDisplay(spawn2.maxHP, spawn2.maxHP-3,false)
