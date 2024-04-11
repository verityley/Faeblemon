extends Node3D
class_name Battler
#Holds all battler-specific information, independently for each battler on the field.
@export var battleManager:BattleManager

@export var faebleEntry:Faeble
@export var playerControl:bool
@export var statusBox:StatusBox

@export_category("Main Resources")
@export var currentHP:int
@export var currentEnergy:int
@export var currentSpeed:int
@export var movepoints:int

@export_category("Stat Changes")
@export var brawnStage:int = 0
@export var vigorStage:int = 0
@export var witStage:int = 0
@export var ambitionStage:int = 0
@export var graceStage:int = 0
@export var resolveStage:int = 0

@export_category("Status Conditions")
@export var decayBuildup:int = 0 #Tick damage, and reduces Vigor
@export var decayed:bool = false
@export var charmBuildup:int = 0 #Prevents moving away from source, and reduces Brawn
@export var charmSource:Node 
@export var charmed:bool = false
@export var fearBuildup:int = 0 #Prevents moving towards the source, and reduces Wit
@export var fearSource:Node
@export var afraid:bool = false
@export var stopBuildup:int = 0 #Prevents movement, and reduces Grace
@export var stopped:bool = false
@export var quietBuildup:int = 0 #Reduces maximum attack range (never below minimum), and reduces Ambition
@export  var silenced:bool = false
@export var sleepBuildup:int = 0 #Prevents action until cured, either by time or attack hitting, and reduces Resolve
@export  var asleep:bool = false
var cureTurns:int = 3 #Might replace with slow reduction instead

@export_category("Binary Statuses")
@export var enlargeStatus:bool = false #Gives a "buffer" for attack ranges to hit this target, but increases physical stats
@export var shrinkStatus:bool = false #This target counts as 1 further space away for attack ranges (not for min range), but decreases physical stats
@export var cantProvoke:bool = false #Cannot provoke opportunity attacks, even if other things would normally.
@export var mustProvoke:bool = false #This supercedes cantProvoke, and guarantees that the enemy may provoke.
@export var blockMovement:bool = false

@export_category("Visual Information")
@export var positionIndex:Vector2i
@export var facingFlip:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func ResetStats():
	pass

func ResetSpeed():
	var speedMod:int = 5
	var pointsMod:int = 0
	#if speed reduce status threshold met, -x on speedmod
	#if speed stage up or down, +x to speedmod
	#if solo, +1 pointsmod
	currentSpeed = faebleEntry.grace + speedMod
	movepoints = currentSpeed/5 + pointsMod
	#Might need changed, doesn't give the player a good sense for order during that turn
	statusBox.ResetSpeed(currentSpeed, movepoints)
	

func ChangeHealth(amount:int):
	print("Taking ", amount, " Damage!")
	currentHP = clampi(currentHP+amount, 0, faebleEntry.maxHP)
	if currentHP == 0:
		faebleEntry.fainted = true
		battleManager.RemoveBattler(self)
		return
	statusBox.SetHealthDisplay(currentHP) #Include handling for hitting 0, going over max, etc

func ChangeMana(amount:int):
	if currentEnergy - amount < 0:
		print("Not enough Energy!")
		return false
	currentEnergy = clampi(currentEnergy+amount, 0, faebleEntry.maxEnergy)
	statusBox.SetEnergyDisplay(currentEnergy)

func ChangeSpeed(amount:int):
	currentSpeed = clampi(currentSpeed+amount, 0, faebleEntry.grace)
	#needs to account for stage increase/decrease, current solution is messy
	statusBox.SetSpeedDisplay(currentSpeed)

func ChangeMovepoints(amount:int):
	movepoints = clampi(movepoints+amount, 0, 8)
	statusBox.SetMovepointsDisplay(movepoints)
	ChangeSpeed(amount*5)

func ChangeStatus():
	pass #Include handling for hitting half, hitting full, reducing past thresholds, etc

func ChangeStage():
	pass

