extends Node3D

@export var battleManager:Node3D

#External Variables
var combatDistance:int

#Setup Variables
@export var playerObject:Node3D
@export var enemyObject:Node3D
@export var leftBound:Vector3 = Vector3(-1.65, -0.5, -2.065)
@export var rightBound:Vector3 = Vector3(-1.65, -0.5, 2.065)
@export var maxDistance:int = 10
@export var centerBuffer:float = 0.3
@export var movetime = 0.5

#Internal Variables
@onready var playerPos:Vector3 = playerObject.position
@onready var enemyPos:Vector3 = enemyObject.position
@onready var fieldSpan:float = absf(leftBound.z - rightBound.z)

#Setup Functions
func _ready():
	combatDistance = 5
	ChangePositions(maxDistance)
	#await get_tree().create_timer(2.0).timeout
	#ChangeDistance(1)
	#await get_tree().create_timer(0.5).timeout
	#ChangeDistance(2)
	#await get_tree().create_timer(0.5).timeout
	#ChangeDistance(-1)
	#await get_tree().create_timer(0.5).timeout
	#ChangeDistance(-3)
	#await get_tree().create_timer(0.5).timeout
	#ChangeDistance(-5)
	#await get_tree().create_timer(0.5).timeout
	#ChangeDistance(3)
	pass

#Data-Handling Functions
func ChangeDistance(amount:int):
	#Check if valid space to expand distance, clamp at max, then change position, tween, and animate
	if combatDistance == maxDistance and amount > 0:
		return
	if combatDistance == 0 and amount < 0:
		return
	combatDistance = clampi(combatDistance + amount, 0, maxDistance)
	print("New Distance: ", combatDistance)
	
	if amount > 0:
		#ChangePositions(combatDistance)
		AnimatePosition(combatDistance, true) #Play forward movement animation
	if amount < 0:
		#ChangePositions(combatDistance)
		AnimatePosition(combatDistance, false) #Play backward animation
	

#Tangible Action Functions
func ChangeFaeble(): #Swaps out the mesh texture for given battler, and adjusts height and scale.
	pass

func ChangePositions(targetDistance:int): #Directly set positions for battlers along the stage line.
	var midpoint:Vector3 = Vector3(leftBound.x, leftBound.y, 0)
	var factor:float = float(maxDistance - targetDistance) / float(maxDistance)
	print("Lerp Factor: ", factor)
	var newplayerpos = leftBound.lerp(midpoint - Vector3(0,0,centerBuffer), factor)
	prints(leftBound.z, newplayerpos.z)
	playerObject.position = newplayerpos
	var newenemypos = rightBound.lerp(midpoint + Vector3(0,0,centerBuffer), factor)
	prints(rightBound.z, newenemypos.z)
	enemyObject.position = newenemypos
	combatDistance = targetDistance

func AnimatePosition(targetDistance:int, forward:bool): #Sequence animation and tweens for simultaneous battler movement.
	var midpoint:Vector3 = Vector3(leftBound.x, leftBound.y, 0)
	var factor:float = float(maxDistance - targetDistance) / float(maxDistance)
	var playertween = get_tree().create_tween()
	var enemytween = get_tree().create_tween()
	#print("Lerp Factor: ", factor)
	var newplayerpos = leftBound.lerp(midpoint - Vector3(0,0,centerBuffer), factor)
	#prints(leftBound, newplayerpos)
	#playerObject.position = newplayerpos
	playertween.tween_property(playerObject, "position", newplayerpos, movetime)
	var newenemypos = rightBound.lerp(midpoint + Vector3(0,0,centerBuffer), factor)
	enemytween.tween_property(enemyObject, "position", newenemypos, movetime)
	#prints(rightBound, newenemypos)
	#enemyObject.position = newenemypos
	await playertween.finished and enemytween.finished
	print("Movement Complete!")
