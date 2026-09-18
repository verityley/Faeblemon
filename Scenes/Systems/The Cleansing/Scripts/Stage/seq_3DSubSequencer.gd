extends Node3D

@export var scene3D:BattleActors
@export var battleSystem:BattleSystemFINAL

func _ready():
	EventBus.connect("Selection",Selection)
	EventBus.connect("AttackResults",AttackResults)
	EventBus.connect("StatusResults",StatusResults)
	EventBus.connect("HealthChanged",HealthChanged)
	EventBus.connect("GuardChanged",GuardChanged)
	EventBus.connect("StatusChanged",StatusChanged)
	EventBus.connect("BuildupChanged",BuildupChanged)
	EventBus.connect("StageChanged",StageChanged)
	EventBus.connect("FaebleMoved",FaebleMoved)
	EventBus.connect("FaebleFainted",FaebleFainted)
	EventBus.connect("FaebleSwitched",FaebleSwitched)


func Setup3D():
	pass


func Selection(playerSent:bool, action:int, option:int, detail:int):
	pass


func AttackResults(target:BattlerData, results:Dictionary):
	var ui:Node3D
	if target == battleSystem.playerBattler:
		ui = scene3D.actors[scene3D.Actors.pUI]
	elif target == battleSystem.enemyBattler:
		ui = scene3D.actors[scene3D.Actors.eUI]
	
	var actor:Node3D
	if target == battleSystem.playerBattler:
		actor = scene3D.actors[scene3D.Actors.pFaeble]
	elif target == battleSystem.enemyBattler:
		actor = scene3D.actors[scene3D.Actors.eFaeble]
	
	var weak:bool
	var resist:bool
	if results["MatchupMult"] > 0:
		weak = true
	if results["MatchupMult"] < 0:
		resist = true
	var graze:bool = results["Missed"]
	var crit:bool = results["Crit"]
	ui.HealthPop(results["Damage"],weak,resist,graze,crit)
	actor.MoveBy(Vector3(0,-0.2,0), true, 0.3)


func StatusResults(target:BattlerData, results:Dictionary, amount:int, type:Enums.Status):
	var ui:Node3D
	if target == battleSystem.playerBattler:
		ui = scene3D.actors[scene3D.Actors.pUI]
	elif target == battleSystem.enemyBattler:
		ui = scene3D.actors[scene3D.Actors.eUI]
	var weak:bool
	var resist:bool
	if results["MatchupMult"] > 0:
		weak = true
	if results["MatchupMult"] < 0:
		resist = true
	var graze:bool = results["Missed"]
	var crit:bool = results["Crit"]
	ui.StatusPop(amount, type, weak, resist, graze, crit)


func HealthChanged(target:BattlerData, amount:int):
	var ui:Node3D
	if target == battleSystem.playerBattler:
		ui = scene3D.actors[scene3D.Actors.pUI]
	elif target == battleSystem.enemyBattler:
		ui = scene3D.actors[scene3D.Actors.eUI]
	
	var actor:Node3D
	if target == battleSystem.playerBattler:
		actor = scene3D.actors[scene3D.Actors.pFaeble]
	elif target == battleSystem.enemyBattler:
		actor = scene3D.actors[scene3D.Actors.eFaeble]
	
	ui.HealthPop(amount,false,false,false,false)
	actor.MoveBy(Vector3(0,-0.2,0), true, 0.3)
	
	pass #might already be covered by attack results? otherwise have recoil animation


func GuardChanged(target:BattlerData, magical:bool, active:bool):
	var ui:Node3D
	if target == battleSystem.playerBattler:
		ui = scene3D.actors[scene3D.Actors.pUI]
	elif target == battleSystem.enemyBattler:
		ui = scene3D.actors[scene3D.Actors.eUI]
	if magical:
		if active: ui.GuardPop(true, true)
		else: ui.GuardPop(true, false)
	else:
		if active: ui.GuardPop(false, true)
		else: ui.GuardPop(false, false)
	


func StatusChanged(target:BattlerData,full:bool):
	pass #Tint or animate battler sprite


func BuildupChanged(target:BattlerData, amount:int, type:Enums.Status):
	pass #Might already be covered by status results?


func StageChanged(target:BattlerData, stat:Enums.BuffableAttrs, amount:int):
	var ui:Node3D
	if target == battleSystem.playerBattler:
		ui = scene3D.actors[scene3D.Actors.pUI]
	elif target == battleSystem.enemyBattler:
		ui = scene3D.actors[scene3D.Actors.eUI]
	ui.BuffPop(stat, amount)


func FaebleMoved(range:Enums.Ranges):
	scene3D.actors[scene3D.Actors.pFaeble].FaebleMoved(range)
	scene3D.actors[scene3D.Actors.eFaeble].FaebleMoved(range)
	scene3D.actors[scene3D.Actors.stage].ChangeRange(range)


func FaebleFainted(target:BattlerData):
	var actor:Node3D
	if target == battleSystem.playerBattler:
		actor = scene3D.actors[scene3D.Actors.pFaeble]
	elif target == battleSystem.enemyBattler:
		actor = scene3D.actors[scene3D.Actors.eFaeble]
	actor.MoveHide(actor.position+Vector3(0,-10,0))
	pass #Hide Faeble Actor (need to make this function on actors)


func FaebleSwitched(target:BattlerData):
	var actor:Node3D
	if target == battleSystem.playerBattler:
		actor = scene3D.actors[scene3D.Actors.pFaeble]
	elif target == battleSystem.enemyBattler:
		actor = scene3D.actors[scene3D.Actors.eFaeble]
	actor.SwitchFaeble(target)
