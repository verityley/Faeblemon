extends Node3D
class_name CapPathManager

@export var captureSystem:Node3D
var disabled:bool
#Path movement limits are z-2.3 z2.3

#External Variables
var pathing:bool


#Setup Variables
@export var faebleObject:Node3D
@export var stageProps:Array[Node3D]
@export var peekTime:float
@export var duckTime:float
@export var stageCenter:Vector3

enum PathAction{
	Wait = 0, #Float for delay time
	Move, #Vector3 represents position
	Hide, #Get stage prop index, use position of prop, float for time
	Peek, #Vector3 represents rotation
	Pose #Float for pose time
}
	

#Internal Variables
@export var testfaeble:Faeble
@export var testPath:CapturePath
@export var testPath2:CapturePath
@onready var hitbox:Area3D = faebleObject.get_child(0)
@onready var faebleMesh:MeshInstance3D = faebleObject.get_child(1)


#Setup Functions
func _ready():
	pass
	#ChangeFaeble(testfaeble)
	#await get_tree().create_timer(4).timeout
	#await PathSequencer(testPath)
	#await PathSequencer(testPath2)

func ChangeFaeble(faeble:Faeble):
	hitbox.get_child(0).position = faeble.centerPosition
	hitbox.get_child(1).set_polygon(faeble.colliderShape)
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

#Process Functions


#Data-Handling Functions
func PathSequencer(currentPath:CapturePath):
	#Every Path is a dictionary consisting of three arrays:
	#Nodes[vector3s], Actions[enum], and Timing[floats]
	var index:int = 0
	var node:Vector3
	var timing:float
	pathing = true
	for action in currentPath.path["Actions"]:
		node = currentPath.path["Nodes"][index]
		timing = currentPath.path["Timing"][index]
		match action:
			PathAction.Wait:
				await WaitAtNode(timing)
			PathAction.Move:
				await MoveToNode(node, timing)
			PathAction.Hide:
				await HideAtObject(timing)
			PathAction.Peek:
				await PeekAtNode(node, timing)
			PathAction.Pose:
				await PoseAtNode(timing)
		index += 1
	pathing = false
	#Play next queued path

#Tangible Action Functions
func WaitAtNode(time:float):
	#Play Idle Animation, random chance for look back n forth
	print("Waiting")
	await get_tree().create_timer(time).timeout

func MoveToNode(target:Vector3, time:float):
	#Play walking anim
	prints("Moving", target)
	var tween = get_tree().create_tween()
	tween.tween_property(faebleObject, "position", target+stageCenter, time)
	await tween.finished

func HideAtObject(time:float):
	pass #TEMP, selects random or closest prop from stage array list, and tweens to.

func PeekAtNode(target:Vector3, time:float):
	var tween = get_tree().create_tween()
	var origin:Vector3 = faebleObject.rotation
	print("Peeking")
	if target == Vector3.ZERO:
		pass #Randomize peek direction if no target
	else:
		target = Vector3(deg_to_rad(target.x),deg_to_rad(target.y),deg_to_rad(target.z))
	tween.tween_property(faebleObject, "rotation", target, peekTime)
	await tween.finished
	await get_tree().create_timer(time).timeout
	tween = get_tree().create_tween()
	tween.tween_property(faebleObject, "rotation", origin, peekTime)
	await tween.finished

func PoseAtNode(time:float): #PoseAnim:?
	pass #Play pose animation
	await get_tree().create_timer(time).timeout

#placeholder order of operations:
#Setup or change out the mesh, shadow, center, and collider vector array
#Import path dictionary for stage environment
#Determine where foreground props are, add to array for potential points
#Add "peek" points for every prop, or maybe a peek vector?
#Once path is started sequencing, tween from point to point in order of path
#Change mesh facing based on movement direction, rotate from stick base point for peeking
#Signal to Behavior Manager when a path is complete
