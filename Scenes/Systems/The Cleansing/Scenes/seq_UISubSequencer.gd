extends Node3D

@export var sceneUI:UIScene
@export var battleSystem:BattleSystemFINAL

var deathSwitch:bool
var playerSelect:bool #TEMP
var enemySelect:bool #TEMP
var queueSelect:bool #TEMP

func _ready():
	EventBus.connect("Selection",Selection)
	EventBus.connect("AttackResults",AttackResults)
	EventBus.connect("StatusResults",StatusResults)
	EventBus.connect("HealthChanged",HealthChanged)
	#EventBus.connect("GuardChanged",GuardChanged)
	EventBus.connect("StatusChanged",StatusChanged)
	EventBus.connect("BuildupChanged",BuildupChanged)
	#EventBus.connect("StageChanged",StageChanged)
	EventBus.connect("FaebleMoved",FaebleMoved)
	EventBus.connect("FaebleFainted",FaebleFainted)
	EventBus.connect("FaebleSwitched",FaebleSwitched)
	



func Selection(playerSent:bool, action:int, option:int, detail:int):
	pass #Hide ui, most likely?


func AttackResults(target:BattlerData, results:Dictionary):
	HealthChanged(target,results["Damage"])
	pass #Change bookmark health containers


func StatusResults(target:BattlerData, results:Dictionary, amount:int, type:Enums.Status):
	BuildupChanged(target,amount,type)
	pass #Change bookmark health containers


func HealthChanged(target:BattlerData, amount:int):
	if target == battleSystem.playerBattler:
		sceneUI.pBookmark.HealthChanged(target, amount)
	if target == battleSystem.enemyBattler:
		sceneUI.eBookmark.HealthChanged(target, amount)
	pass #Change bookmark health containers


#func GuardChanged(target:BattlerData, magical:bool, double:bool):
	#pass #No change?


func StatusChanged(target:BattlerData,full:bool):
	if target == battleSystem.playerBattler:
		sceneUI.pBookmark.StatusChanged(target,full)
	if target == battleSystem.enemyBattler:
		sceneUI.eBookmark.StatusChanged(target,full)
	
	pass #Change bookmark status label


func BuildupChanged(target:BattlerData, amount:int, type:Enums.Status):
	if target == battleSystem.playerBattler:
		sceneUI.pBookmark.BuildupChanged(target, amount, type)
	if target == battleSystem.enemyBattler:
		sceneUI.eBookmark.BuildupChanged(target, amount, type)
	
	pass #Change bookmark buildup meter


#func StageChanged(target:BattlerData, stat:Enums.BuffableAttrs, amount:int):
	#pass #Change relevant inspect menu


func FaebleMoved(range:Enums.Ranges):
	sceneUI.rangefinder.DistanceChanged(range)
	pass #Change distance dial


func FaebleFainted(target:BattlerData):
	deathSwitch = true
	if target == battleSystem.playerBattler:
		playerSelect = true
		#await TempPrepSwitch()
		print("Player Fainted, prompting UI")
	if target == battleSystem.enemyBattler:
		enemySelect = true
		#await TempPrepSwitch()
		print("Enemy Fainted, prompting UI")
	if playerSelect and enemySelect:
		queueSelect = true
		print("Both Fainted, prompting queue")
	pass #Prompt switch?


func FaebleSwitched(target:BattlerData):
	if target == battleSystem.playerBattler:
		sceneUI.pBookmark.SetupBookmark(target)
		sceneUI.commandBook.PopulateAttacks(target)
	elif target == battleSystem.enemyBattler:
		sceneUI.eBookmark.SetupBookmark(target)
	pass #Change bookmarks out
