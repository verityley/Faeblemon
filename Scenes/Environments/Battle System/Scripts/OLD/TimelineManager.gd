extends Node3D

@export var battleManager:Node3D

#External Variables
var roundTime:int
var activeFaeble:Faeble
var waiting:bool

#Setup Variables
@export var roundHand:Node3D
@export var pfHand:Node3D
@export var pwHand:Node3D
@export var efHand:Node3D
@export var ewHand:Node3D
@export var tickInterval:float
@export var tickTime:float
@export var tickPauseTime:float
@export var roundDuration:int

#Internal Variables
@onready var pfPortrait:Sprite3D = pfHand.get_child(0)
@onready var pwPortrait:Sprite3D = pwHand.get_child(0)
@onready var efPortrait:Sprite3D = efHand.get_child(0)
@onready var ewPortrait:Sprite3D = ewHand.get_child(0)
var pfTime:int
var pwTime:int
var efTime:int
var ewTime:int



#Setup Functions
func _ready():
	pass
	waiting = false
	RoundTick()

#Data-Handling Functions


#Tangible Action Functions
func RoundTick():
	for tick in range(roundDuration):
		roundTime += 1
		TickHand(roundHand, 1)
		TickHand(pfHand, 5)
		TickHand(efHand, 4)
		TickHand(pwHand, 3)
		TickHand(ewHand, 2)
		await get_tree().create_timer(tickInterval + 0.05).timeout
		if roundTime >= roundDuration:
			return

func TickHand(hand:Node3D, tickMulti:float):
	var intervalRotation:float = deg_to_rad(360 / (roundDuration / tickMulti))
	var rotationTarget = hand.rotation - Vector3(0, intervalRotation, 0)
	await get_tree().create_timer(tickPauseTime).timeout #TEMP Replace with looping timer
	#prints("Tick!", rotationTarget, hand.rotation)
	var tween = get_tree().create_tween()
	tween.tween_property(hand, "rotation", rotationTarget, tickTime)
	await tween.finished
	#prints("Tock!")
