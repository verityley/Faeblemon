extends Node3D
class_name BattleScene3D

@export var battleSystem:BattleSystemFINAL
var currentPlayer:BattlerData
var currentEnemy:BattlerData

@export var stageSystem:StageSystem
@export var actors:Dictionary[Enums.Actors,Node3D]
@export var anchorLayers:Dictionary[Enums.Actors,Node3D]
@export var anchorLocations:Dictionary[Enums.Actors,Vector3]

@export var healthOffset:float = -2.5

var sceneRange:Enums.Ranges



@export var stageResource:Stage

func _ready():
	#EventBus.connect("BattleStart",BattleStart)
	stageResource = preload("res://Scenes/Environments/World Scenes/Forest/Resources/SparseForest.tres")
	#EventBus.connect("FaebleSwitched",SwitchFaeble)
	#EventBus.connect("HealthChanged", ChangeHealth)
	currentPlayer = battleSystem.playerBattler
	currentEnemy = battleSystem.enemyBattler
	#ActorSetup()
	


func ActorSetup():
	actors[Enums.Actors.pFaeble].reparent(anchorLayers[Enums.Actors.pFaeble],false)
	actors[Enums.Actors.pFaeble].position = anchorLocations[Enums.Actors.pFaeble]
	actors[Enums.Actors.pFaeble].attached = currentPlayer
	actors[Enums.Actors.pFaeble].homeTarget = anchorLocations[Enums.Actors.pFaeble]
	actors[Enums.Actors.pFaeble].shiftTarget = anchorLocations[Enums.Actors.pFaeble] + Vector3(-5,-3,0)
	actors[Enums.Actors.pFaeble].rangeTargets[Enums.Ranges.Melee] = anchorLocations[Enums.Actors.pFaeble] + Vector3(0.5,0,0)
	actors[Enums.Actors.pFaeble].rangeTargets[Enums.Ranges.Near] = anchorLocations[Enums.Actors.pFaeble]
	actors[Enums.Actors.pFaeble].rangeTargets[Enums.Ranges.Far] = anchorLocations[Enums.Actors.pFaeble] + Vector3(-0.5,0,0)
	
	actors[Enums.Actors.pWitch].reparent(anchorLayers[Enums.Actors.pWitch],false)
	actors[Enums.Actors.pWitch].position = anchorLocations[Enums.Actors.pWitch]
	
	actors[Enums.Actors.pUI].reparent(anchorLayers[Enums.Actors.pUI],false)
	actors[Enums.Actors.pUI].position = anchorLocations[Enums.Actors.pUI]
	actors[Enums.Actors.pUI].attached = currentPlayer
	#actors[Actors.pUI].position.y += healthOffset
	
	actors[Enums.Actors.eFaeble].reparent(anchorLayers[Enums.Actors.eFaeble],false)
	actors[Enums.Actors.eFaeble].position = anchorLocations[Enums.Actors.eFaeble]
	actors[Enums.Actors.eFaeble].attached = currentEnemy
	actors[Enums.Actors.eFaeble].homeTarget = anchorLocations[Enums.Actors.eFaeble]
	actors[Enums.Actors.eFaeble].shiftTarget = anchorLocations[Enums.Actors.eFaeble] + Vector3(5,-3,0)
	actors[Enums.Actors.eFaeble].rangeTargets[Enums.Ranges.Melee] = anchorLocations[Enums.Actors.eFaeble] + Vector3(-0.5,0,0)
	actors[Enums.Actors.eFaeble].rangeTargets[Enums.Ranges.Near] = anchorLocations[Enums.Actors.eFaeble]
	actors[Enums.Actors.eFaeble].rangeTargets[Enums.Ranges.Far] = anchorLocations[Enums.Actors.eFaeble] + Vector3(0.5,0,0)
	
	actors[Enums.Actors.eWitch].reparent(anchorLayers[Enums.Actors.eWitch],false)
	actors[Enums.Actors.eWitch].position = anchorLocations[Enums.Actors.eWitch]
	
	actors[Enums.Actors.eUI].reparent(anchorLayers[Enums.Actors.eUI],false)
	actors[Enums.Actors.eUI].position = anchorLocations[Enums.Actors.eUI]
	actors[Enums.Actors.eUI].attached = currentEnemy
	#actors[Actors.eUI].position.y += healthOffset + 2.5
	
	actors[Enums.Actors.camera].reparent(anchorLayers[Enums.Actors.camera],false)
	actors[Enums.Actors.camera].position = anchorLocations[Enums.Actors.camera]
	actors[Enums.Actors.camera].anchor = anchorLocations[Enums.Actors.camera]
	
	#actors[Actors.commands].reparent(anchorLayers[Actors.commands],false)
	#actors[Actors.commands].position = anchorLocations[Actors.commands]

#
#func SwitchFaeble(target:BattlerData):
	##print("Changing 3D Faeble")
	#var faebleMesh:MeshInstance3D
	##var healthDisplay:HealthManager
	#var entry:Faeble = target.instance
	#if target == currentPlayer:
		#faebleMesh = actors[Enums.Actors.pFaeble].get_child(0)
		##healthDisplay = actors[Actors.pUI].get_child(0)
	#elif target == currentEnemy:
		#faebleMesh = actors[Enums.Actors.eFaeble].get_child(0)
		##healthDisplay = actors[Actors.eUI].get_child(0)
	#
	#var texture:Material
	#texture = faebleMesh.get_surface_override_material(0)
	#texture.albedo_texture = entry.sprite
	#faebleMesh.set_surface_override_material(0, texture)
	#faebleMesh.position = entry.groundOffset
	#faebleMesh.scale = entry.battlerScale
	##healthDisplay.position.y = entry.height + entry.groundOffset.y - healthOffset
	##healthDisplay.MaxHealthReset(entry.maxHP)
	##healthDisplay.SetHealthDisplay(entry.maxHP, target.health)
