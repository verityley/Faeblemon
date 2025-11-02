extends Node3D
class_name MapBlock
@export var overworldManager:OverworldManager

@export var frontAnchor:Node3D
@export var backAnchor:Node3D
@export var contextCam:Node3D
@export var contextHome:Vector3
@export var contextTarget:Vector3
@export var nodeID:Vector3i #use this for referencing and tracking across district

@export var hideDistance:float = -5.0
@export var stairsTime:float = 0.4
@export var stairPathway:Array[Vector3]
var threshold #Placeholder, replace with spawn info
var blocked:bool #if barrier is deactivated or not, reset every day
var barrier #Placeholder, replace with threshold obstacle info

var currentNPCs:Array[NPC]

func _ready() -> void:
	SlideFront(false)
	#await get_tree().create_timer(2.0).timeout
	#await SlideFront(true)
	#await get_tree().create_timer(2.0).timeout
	#await SlideFront(false)

func SlideFront(show:bool=false):
	if frontAnchor == null:
		return
	if show: #Show/Hide front anchor set of layers, except railing
		var tween = get_tree().create_tween()
		frontAnchor.show()
		tween.tween_property(frontAnchor, "position:y", 0, 0.3)
		await tween.finished
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(frontAnchor, "position:y", hideDistance, 0.3)
		await tween.finished
		frontAnchor.hide()

func SlideBack(show:bool=false):
	if backAnchor == null:
		return
	if show:
		var tween = get_tree().create_tween()
		backAnchor.show()
		tween.tween_property(backAnchor, "position:y", 0, 0.3)
		await tween.finished
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(backAnchor, "position:y", hideDistance, 0.3)
		await tween.finished
		backAnchor.hide()

func StairEntry(_body):
	var player = overworldManager.player
	if player.forceMoving == true:
		return
	for npc:NPC in currentNPCs:
		npc.EndPassby()
	contextCam.position = contextHome
	overworldManager.camera.tempTarget = contextCam
	var camTween = get_tree().create_tween()
	camTween.tween_property(contextCam, "position", contextTarget, 4.0)
	player.forceMoving = true
	print("Moving down stairs")
	for node in stairPathway:
		var tween = get_tree().create_tween()
		var globalNode = to_global(node)
		if globalNode.x > player.global_position.x:
			print("Turning Player Right")
			player.inputDir.x = 1
		elif globalNode.x < player.global_position.x:
			print("Turning Player Left")
			player.inputDir.x = -1
		var time = abs(player.global_position - globalNode).length()*stairsTime
		tween.tween_property(player, "global_position", globalNode, time)
		await tween.finished
		#player.navAgent.target_position = globalNode
	contextCam.position = contextTarget
	player.forceMoving = false
	player.inputDir.x = 0
	overworldManager.camera.tempTarget = null
	contextCam.position = contextHome
	pass #signal connection to stair trigger zone, include some kind of disable for the exit point collider
#Also needs to work for both top stair and bottom stair entry, top has "landings" and bottom has inclines

func ThresholdEntry(scene): #replace scene with relevant investigation scene link resource
	pass #signal connection to threshold, divert to barrier UI inquiry if blocked
	#call signal up to overworld manager, telling it to lock down overworld and scene transition

func DistrictEntry(scene):
	pass #similar to above, but switch out to other overworld scene, call signal up to overworld manager

func PassbyEntry(body:Area3D=null, enter:bool=true):
	var enterChar:Node3D = body.get_parent_node_3d().get_parent_node_3d()
	if enterChar is not NPC:
		enterChar = body.get_parent_node_3d()
	if enterChar == overworldManager.player:
		if enter:
			for npc:NPC in currentNPCs:
				print("Sending Passby Signal")
				EventBus.emit_signal("PassbyNPC", npc)
				await get_tree().create_timer(0.1).timeout
		else:
			for npc:NPC in currentNPCs:
				print("Sending Cancel Signal")
				EventBus.emit_signal("CancelEvents", npc)
				await get_tree().create_timer(0.1).timeout
	else:
		if enter:
			#print("Adding NPC to Block")
			currentNPCs.append(enterChar)
		else:
			currentNPCs.erase(enterChar)
	pass #if NPC/crowd is present and Sighting message assigned, display bubble when trigger zone entered
	#overworld manager itself will have system for message assignment
