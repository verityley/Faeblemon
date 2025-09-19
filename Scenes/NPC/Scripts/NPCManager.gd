extends Node3D
class_name NPC
@export var overworld:OverworldManager
@export var NPCName:String

@export var rumor:Message #Usually empty, assigned by nearby Thresholds

@export_category("Movement Variables")
@export var stepSpeed:float = 2.5
@export var stopThreshold:float = 0.45
@export var navAgent:NavigationAgent3D
@export var charSprite:MeshInstance3D
@export var moveTarget:Vector3
var playerFollow:bool = false
var forceMoving:bool = false
var lockdown:bool = false

func _ready() -> void:
	overworld.allNPCs.append(self)
	

func _physics_process(delta: float):
	if lockdown: #In overlay scene, such as an investigation, or during interaction
		return
	if navAgent == null:
		return #if static NPC, ignore all pathfinding logic
	if playerFollow:
		moveTarget = overworld.player.position
	navAgent.target_position = moveTarget
	if to_global(moveTarget) == global_position:
		return
	var target:Vector3 = navAgent.get_next_path_position() - global_position
	if target.x > 0 and charSprite.rotation.y != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(charSprite, "rotation", Vector3(deg_to_rad(0),deg_to_rad(0),deg_to_rad(0)), 0.1)
	elif target.x < 0 and charSprite.rotation.y != 180:
		var tween = get_tree().create_tween()
		tween.tween_property(charSprite, "rotation", Vector3(deg_to_rad(0),deg_to_rad(180),deg_to_rad(0)), 0.1)
	if forceMoving:
		return
	target = navAgent.get_next_path_position() - global_position
	#target.y += height
	#print(target)
	if target.length() <= stopThreshold:
		return
		print("Stuck")
	global_position.x += target.normalized().x * stepSpeed * delta
	global_position.z += target.normalized().z * stepSpeed * delta
	global_position.y += target.normalized().y * stepSpeed * delta

func AssignRumor():
	pass

func Passby():
	if lockdown:
		return

func EndPassby():
	pass
