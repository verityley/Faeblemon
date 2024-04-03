extends Node3D
class_name Battler
#Holds all battler-specific information, independently for each battler on the field.
@export var faebleEntry:Faeble
@export var playerControl:bool

@export_category("Main Resources")
@export var currentHP:int
@export var currentEnergy:int
@export var currentSpeed:int
@export var movepoints:int

@export_category("Stat Changes")
@export var strStage:int = 0
@export var dexStage:int = 0
@export var conStage:int = 0
@export var wisStage:int = 0
@export var intStage:int = 0
@export var chaStage:int = 0

@export_category("Status Conditions")
@export var decayBuildup:int = 0 #Tick damage, and reduces Constitution
@export var decayed:bool = false
@export var charmBuildup:int = 0 #Prevents moving away from source, and reduces Strength
@export var charmSource:Node 
@export var charmed:bool = false
@export var fearBuildup:int = 0 #Prevents moving towards the source, and reduces Intelligence
@export var fearSource:Node
@export var afraid:bool = false
@export var stopBuildup:int = 0 #Prevents movement, and reduces Dexterity
@export var stopped:bool = false
@export var quietBuildup:int = 0 #Reduces maximum attack range (never below minimum), and reduces Charisma
@export  var silenced:bool = false
@export var sleepBuildup:int = 0 #Prevents action until cured, either by time or attack hitting, and reduces Wisdom
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

func ChangeHealth():
	pass #Include handling for hitting 0, going over max, etc

func ChangeMana():
	pass

func ChangeSpeed():
	pass

func ChangeMovepoints():
	pass

func ChangeStatus():
	pass #Include handling for hitting half, hitting full, reducing past thresholds, etc

func ChangeStage():
	pass

