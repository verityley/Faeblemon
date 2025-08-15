extends Node3D


#@export var stepDistance:float = 0.5
@export var stepSpeed:float = 2.5
@export var stopThreshold:float = 0.45

@export var navAgent:NavigationAgent3D
#@export var navMap:NavigationRegion3D
@export var charSprite:MeshInstance3D

@export var moving:bool = false
@export var moveTarget:Vector3

func _physics_process(delta: float):
	if !moving:
		print("Waiting")
		return
	navAgent.target_position = moveTarget
	var target:Vector3 = navAgent.get_next_path_position() - global_position
	if target.length() <= stopThreshold:
		print("Stuck")
		return
	if target.x > 0 and charSprite.rotation.y != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(charSprite, "rotation", Vector3(deg_to_rad(0),deg_to_rad(0),deg_to_rad(0)), 0.1)
	elif target.x < 0 and charSprite.rotation.y != 180:
		var tween = get_tree().create_tween()
		tween.tween_property(charSprite, "rotation", Vector3(deg_to_rad(0),deg_to_rad(180),deg_to_rad(0)), 0.1)
	global_position += target.normalized() * stepSpeed * delta
	global_position.y = 0.7
	#if navAgent.target_reached:
		#print("Finished")
		#moving = false
	#move_and_slide()
	pass #if direction doesnt equal velocity, cancel current path and recalculate
