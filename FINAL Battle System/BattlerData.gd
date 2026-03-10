extends Node
class_name BattlerData

@export var instance:Faeble
@export var witchInstance:Witch

@export var faebleTeam:Array[Faeble]

var health:int #Resource that means Not Dead
var priority:int #Temporary declaration of turn order tier
var pGuard:int #Temporary resource that goes away after an attack, soaks damage
var mGuard:int
var buildup:int #Status buildup amount
var buildupTarget:Enums.Status #Last hit status target, can't change if over half buildup
var status:Enums.Status #Enum of statuses
var buffStages:Array[int] = [0,0,0,0,0]
var damageBoost:int
var damageTaken:int #Damage taken during this turn
var protected:bool = false #Use to prevent all damage and skip damage calc step
var safeguarded:bool = false #Use to prevent all status buildup and skip status calc step
var switching:bool = false #If true, change battler to currentFaeble when triggered

var currentSpell:Spell
var currentWitchSpell:Spell
var currentTheme:SpellTheme
var currentTactic:Enums.Tactics #Enum of menu tactics option
var currentTarget:BattlerData
var currentFaeble:Faeble #used for party targeting(?)

func ChangeBattler(entry:Faeble):
	if instance != null:
		instance.currentHP = health
		instance.currentStatus = status
		instance.currentBuildup = buildup
		instance.currentBuildupTarget = buildupTarget
		var targetSlot:int = faebleTeam.find(entry)
		faebleTeam[0] = entry
		faebleTeam[targetSlot] = instance
	ResetBattler(true)
	instance = entry
	health = entry.currentHP
	EventBus.emit_signal("HealthChanged", self)
	status = entry.currentStatus
	buildup = instance.currentBuildup
	buildupTarget = instance.currentBuildupTarget

func ResetBattler(fullReset:bool=false):
	#End of Turn Reset
	pGuard = 0
	mGuard = 0
	priority = 0
	damageBoost = 0
	currentSpell = null
	currentWitchSpell = null
	currentTheme = null
	currentTactic = Enums.Tactics.None
	currentFaeble = null
	currentTarget = null
	protected = false
	safeguarded = false
	switching = false
	damageTaken = 0
	#Battler Change/End Reset
	if fullReset:
		buffStages = [0,0,0,0,0]
		status = Enums.Status.Clear
		buildup = 0
		buildupTarget = Enums.Status.Clear
		health = 0

func ClearBattler():
	if instance != null:
		instance.currentHP = health
		instance.currentStatus = status
		instance.currentBuildup = buildup
		instance.currentBuildupTarget = buildupTarget
	ResetBattler(true)
	instance = null
	witchInstance = null
	faebleTeam.clear()
