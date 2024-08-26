extends Node3D
class_name FieldManager

@export var battleManager:Node3D

#External Variables
var combatDistance:int = 10

#Setup Variables
@export var playerObject:Node3D
@export var enemyObject:Node3D
@export var distanceObject:Node3D
@export var leftBound:Vector3 = Vector3(-1.65, -0.5, -2.065)
@export var rightBound:Vector3 = Vector3(-1.65, -0.5, 2.065)
@export var maxDistance:int = 10
@export var centerBuffer:float = 0.3
@export var movetime = 0.5

@export var dialRotation:float = 16
@export var markerRotation:float = 16

#Internal Variables
@onready var playerPos:Vector3 = playerObject.position
@onready var enemyPos:Vector3 = enemyObject.position
@onready var fieldSpan:float = absf(leftBound.z - rightBound.z)
@onready var distanceMarker:Node3D = distanceObject.get_child(0)
@onready var distanceDial:Sprite3D = distanceObject.get_child(1)

#Setup Functions
func _ready():
	#combatDistance = 5
	#ChangeDistance(1)
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
	var distanceMod:int = clampi(combatDistance + amount, 0, maxDistance)
	#Clamp to max, then change position, tween, and animate
	RotateDial(distanceMod)
	await AnimatePosition(distanceMod)
	combatDistance = distanceMod
	print("New Distance: ", combatDistance)

func MoveFaeble(amount:int, player:bool):
	#Moves single faeble, then equalizes. Connect with prop manager eventually
	var distanceMod:int = clampi(combatDistance + amount, 0, maxDistance)
	RotateMarker(-amount)
	await AnimateSingle(amount, player)
	await get_tree().create_timer(0.3).timeout
	RotateDial(distanceMod)
	RotateMarker(amount)
	await AnimatePosition(distanceMod)
	combatDistance = distanceMod

#Tangible Action Functions
func ChangeFaeble(faeble:Faeble, player:bool):
	var faebleMesh:MeshInstance3D
	if player:
		faebleMesh = playerObject.get_child(0)
	else:
		faebleMesh = enemyObject.get_child(0)
	faebleMesh.position = faeble.groundOffset
	faebleMesh.scale = faeble.battlerScale
	var texture = faebleMesh.get_surface_override_material(0)
	texture.albedo_texture = faeble.sprite
	var shadow = faebleMesh.get_child(0)
	#shadow.position = faeble.groundOffset
	#shadow.scale = faeble.battlerScale
	texture = shadow.get_surface_override_material(0)
	texture.albedo_texture = faeble.sprite
	#faebleObject = faeble

func ChangePositions(targetDistance:int): #Directly set positions for battlers along the stage line.
	var midpoint:Vector3 = Vector3(leftBound.x, leftBound.y, 0)
	var factor:float = float(maxDistance - targetDistance) / float(maxDistance)
	#print("Lerp Factor: ", factor)
	var newplayerpos = leftBound.lerp(midpoint - Vector3(0,0,centerBuffer), factor)
	#prints(leftBound.z, newplayerpos.z)
	playerObject.position = newplayerpos
	var newenemypos = rightBound.lerp(midpoint + Vector3(0,0,centerBuffer), factor)
	#prints(rightBound.z, newenemypos.z)
	enemyObject.position = newenemypos
	combatDistance = targetDistance
	print("New Distance Set: ", combatDistance)
	SetDial(targetDistance)


func AnimatePosition(targetDistance:int):
	#Sequence animation and tweens for simultaneous battler movement.
	var midpoint:Vector3 = Vector3(leftBound.x, leftBound.y, 0)
	var factor:float = float(maxDistance - targetDistance) / float(maxDistance)
	var playertween = get_tree().create_tween()
	var enemytween = get_tree().create_tween()
	#print("Lerp Factor: ", factor)
	var newplayerpos = leftBound.lerp(midpoint - Vector3(0,0,centerBuffer), factor)
	#prints(leftBound, newplayerpos)
	#playerObject.position = newplayerpos
	playertween.tween_property(playerObject, "position", newplayerpos, movetime*2)
	var newenemypos = rightBound.lerp(midpoint + Vector3(0,0,centerBuffer), factor)
	enemytween.tween_property(enemyObject, "position", newenemypos, movetime*2)
	#prints(rightBound, newenemypos)
	#enemyObject.position = newenemypos
	await playertween.finished and enemytween.finished
	#print("Movement Complete!")

func AnimateSingle(amount:int, player:bool): 
	#Sequence animation and tweens for single battler movement.
	var factor:float = (float(-amount)/3)
	print("Move Factor: ", factor)
	var tween = get_tree().create_tween()
	#print("Lerp Factor: ", factor)
	var bound:Vector3 = rightBound
	var battler:Node3D = enemyObject
	var targetPos:Vector3 = playerObject.position
	targetPos.z += centerBuffer
	if player:
		bound = leftBound
		battler = playerObject
		targetPos = enemyObject.position
		targetPos.z -= centerBuffer
	var newpos = battler.position.lerp(targetPos, factor)
	newpos.z = clamp(newpos.z, leftBound.z, rightBound.z)
	#prints(leftBound, newplayerpos)
	#playerObject.position = newplayerpos
	tween.tween_property(battler, "position", newpos, movetime)
	#prints(rightBound, newenemypos)
	#enemyObject.position = newenemypos
	await tween.finished
	#print("Movement Complete!")

func SetDial(target:int):
	var rotationAmount:float = (target-1)/dialRotation * TAU
	distanceDial.rotation = Vector3(deg_to_rad(-90),rotationAmount,0)

func RotateDial(target:int):
	var targetRotation:Vector3
	var rotationAmount:float = (target-1)/dialRotation * TAU
	var tween = get_tree().create_tween()
	prints("Rotating Dial To:", target)
	targetRotation = Vector3(deg_to_rad(-90),rotationAmount,0)
	tween.tween_property(distanceDial, "rotation", targetRotation, movetime*2)
	await tween.finished

func RotateMarker(amount:int):
	var targetRotation:Vector3
	var rotationAmount:float
	var tween = get_tree().create_tween()
	print("Rotating By: ", amount)
	rotationAmount = amount/markerRotation * TAU
	targetRotation = distanceMarker.rotation + Vector3(0,rotationAmount,0)
	tween.tween_property(distanceMarker, "rotation", targetRotation, movetime*2)
	await tween.finished
