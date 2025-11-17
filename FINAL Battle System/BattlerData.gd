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
var protected:bool = false #Use to prevent all damage and skip damage calc step
var safeguarded:bool = false #Use to prevent all status buildup and skip status calc step
var switching:bool = false #If true, change battler to currentFaeble when triggered

var currentMove:Skill
var currentSpell:Skill
var currentTheme:SkillTheme
var currentTactic:int #Enum of menu tactics option
var currentTarget:BattlerData
var currentFaeble:Faeble

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
	status = entry.currentStatus
	buildup = instance.currentBuildup
	buildupTarget = instance.currentBuildupTarget

func ResetBattler(fullReset:bool=false):
	#End of Turn Reset
	pGuard = 0
	mGuard = 0
	priority = 0
	damageBoost = 0
	currentMove = null
	currentSpell = null
	currentTheme = null
	currentTactic = 0
	currentFaeble = null
	currentTarget = null
	protected = false
	safeguarded = false
	switching = false
	#Battler Change/End Reset
	if fullReset:
		buffStages = [0,0,0,0,0]
		status = 0
		buildup = 0
		buildupTarget = 0
		health = 0
