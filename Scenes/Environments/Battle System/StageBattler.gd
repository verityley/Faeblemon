extends Node3D
class_name StageBattler

@export var battleSystem:BattleSystem

@export var faebleLayer:int
@export var faeblePoint:Vector3
@export var faebleObject:Node3D
@export var faebleInstance:Faeble
@export var witchLayer:int
@export var witchPoint:Vector3
@export var witchObject:Node3D
@export var witchInstance:Witch
@export var healthDisplay:HealthManager
@export var manaDisplay:ManaManager

@export var player:bool

var health:int #Resource that means Not Dead
var manapool:Array[int] #Resource for skills
var armor:int #Temporary resource that goes away after an attack, soaks damage
var buildup:int #Status buildup amount
var status:int #Enum of statuses
var stance:int #Enum of stances
var buffStages:Array[int] = [0,0,0,0,0]


func BattlerSetup(stageSystem:StageSystem):
	faebleObject.reparent(stageSystem.stageLayers[faebleLayer])
	faebleObject.position = faeblePoint
	witchObject.reparent(stageSystem.stageLayers[witchLayer])
	witchObject.position = witchPoint
	healthDisplay.reparent(stageSystem.stageLayers[faebleLayer])
	healthDisplay.position = faebleObject.position + faebleInstance.UICenter
	manaDisplay.reparent(stageSystem.stageLayers[witchLayer])
	manaDisplay.position = witchPoint #+ offset
	if !player:
		healthDisplay.rotation.y = deg_to_rad(180)
	#eWitchBattler.position = enemyPoint + Vector3(3,-0.25,0)

func BattlerCleanup():
	faebleObject.reparent(self)
	witchObject.reparent(self)
	healthDisplay.reparent(self)
	manaDisplay.reparent(self)
	faebleInstance.currentHP = health
	faebleInstance.currentStatus = 0
	faebleInstance.currentBuildup = 0
	faebleInstance = null
	#hide()
	#queue_free()

func ChangeBattler(entry:Faeble):
	var texture:Material
	texture = faebleObject.get_child(0).get_surface_override_material(0)
	if player:
		texture.albedo_texture = entry.backSprite
	else:
		texture.albedo_texture = entry.sprite
	faebleObject.get_child(0).set_surface_override_material(0, texture)
	faebleObject.position = faeblePoint + entry.groundOffset
	faebleObject.scale = entry.battlerScale
	healthDisplay.position = faebleObject.position + entry.UICenter
	if faebleInstance != null:
		faebleInstance.currentHP = health
		faebleInstance.currentStatus = status
		faebleInstance.currentBuildup = buildup
	healthDisplay.MaxHealthReset(entry.maxHP)
	healthDisplay.SetHealthDisplay(entry.maxHP, entry.currentHP)
	faebleInstance = entry
	health = entry.currentHP
	status = entry.currentStatus
	buildup = entry.currentBuildup

func ChangeWitch(char:Witch):
	var texture:Material
	texture = witchObject.get_child(0).get_surface_override_material(0)
	if player:
		texture.albedo_texture = char.backSprite
	else:
		texture.albedo_texture = char.battleSprite
	witchObject.get_child(0).set_surface_override_material(0, texture)
