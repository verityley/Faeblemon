extends Node3D
class_name BattleSystem

@export var testFaeble1:Faeble
@export var testFaeble2:Faeble

#External Variables
var playerFaeble:Faeble
var enemyFaeble:Faeble
var playerWitch:Witch
var enemyWitch:Witch

#Setup Variables
@export_category("Managers")
@export var commandManager:CapCameraManager
@export var multiplayerManager:CapBehaviorManager
@export var AIManager:CapPathManager
@export var displayManager:CapCameraManager
@export var fieldManager:CapBehaviorManager
@export var messageManager:CapPathManager
@export var fxManager:Node3D
@export var propManager:Node3D

enum Status{
	Clear=0,
	Decay, #Tick damage, and reduces Vigor
	Charm, #Prevents moving away from source, and reduces Brawn
	Fear, #Prevents moving towards the source, and reduces Wit
	Silence, #Reduces maximum attack range (never below minimum), and reduces Ambition
	Slow #Halves stamina gain, and reduces Grace
}

enum Attributes{
	Brawn=0,
	Vigor,
	Wit,
	Ambition,
	Grace,
	Heart
}

#Internal Variables
var pHealth:int #Resource that means Not Dead
var pMana:int #Resource for skills
var pResolve:int #Armor against attacks
var pStamina:int #Available movepoints
var pBuildup:int #Status buildup amount
var pStatus:int #Enum of statuses
var pStages:Array[int] = [0,0,0,0,0]

var eHealth:int #Resource that means Not Dead
var eMana:int #Resource for skills
var eResolve:int #Armor against attacks
var eStamina:int #Available movepoints
var eBuildup:int #Status buildup amount
var eStatus:int #Enum of statuses
var eStages:Array[int] = [0,0,0,0,0]

#Setup Functions
func _ready():
	
	pass

#Process Functions


#Data-Handling Functions


#Tangible Action Functions


#State Machine


#placeholder order of operations:
#Battle start, play intro while swapping faebles to current party/encounter
#Determine if witch vs witch, display alt intro and enable witch actions
#Fold down status plates, display randomized research goals
#Show player UI
#On selection, queue action for turn order
#When both sides selected (or player selected and AI responded), move to turn order
#Turn determined by stamina and speed differences
#Enact queued actions and change relevant resources
#Cleanup, research goal check, restart
