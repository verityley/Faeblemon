extends Node3D


@export var stepDistance:float = 0.5
@export var stepSpeed:float = 2.5
@export var stopThreshold:float = 0.45
@export var height:float = 0.25
@export var stairsTime:float = 0.4
var inputDir:Vector3

@export var navAgent:NavigationAgent3D
@export var charSprite:MeshInstance3D
@export var playerCam:Node3D

var forceMoving:bool = false
var lockdown:bool = false

func _physics_process(delta: float):
	if lockdown:
		return
	if !forceMoving:
		inputDir = Vector3(Input.get_axis("MoveLeft","MoveRight"), 0, Input.get_axis("MoveUp","MoveDown"))
	if inputDir.x > 0 and charSprite.rotation.y != 0:
		#print("Turning Right")
		var tween = get_tree().create_tween()
		tween.tween_property(charSprite, "rotation", Vector3(deg_to_rad(0),deg_to_rad(0),deg_to_rad(0)), 0.1)
	elif inputDir.x < 0 and charSprite.rotation.y != 180:
		#print("Turning Left")
		var tween = get_tree().create_tween()
		tween.tween_property(charSprite, "rotation", Vector3(deg_to_rad(0),deg_to_rad(180),deg_to_rad(0)), 0.1)
	if forceMoving:
		return
	inputDir = inputDir.normalized()
	navAgent.target_position = global_position + inputDir * stepDistance
	var target:Vector3 = navAgent.get_next_path_position() - global_position
	#target.y += height
	#print(target)
	if target.length() <= stopThreshold:
		return
		print("Stuck")
	global_position.x += target.normalized().x * stepSpeed * delta
	global_position.z += target.normalized().z * stepSpeed * delta
	global_position.y += target.normalized().y * stepSpeed * delta
	
	pass #if direction doesnt equal velocity, cancel current path and recalculate

func EnterStairs(body, start:Vector3, end:Vector3):
	forceMoving = true
	print("Moving down stairs")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", start, stairsTime)
	tween.tween_property(self, "global_position", end, abs(start - end).length()*stairsTime)
	await tween.finished
	navAgent.target_position = end
	forceMoving = false
	
