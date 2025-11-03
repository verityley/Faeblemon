extends Node3D

@export var overworld:OverworldManager
@onready var hostNPC:NPC = get_parent()
@onready var events: Node = $Events
@export var tempCamTarget:Node3D


func _ready() -> void:
	EventBus.connect("InteractNPC", Interact)

func Interact(npc:NPC):
	if npc != hostNPC:
		#print("Not for me!")
		return
	#print("Received Interaction Signal")
	hostNPC.lockdown = true
	EventBus.emit_signal("CancelEvents", hostNPC)
	if tempCamTarget != null:
		overworld.camera.tempTarget = tempCamTarget
	for event:Event in events.get_children():
		event.InvokeEvent(hostNPC)
		await event.finished
		print("Event Finished")
	print("All Events Finished")
	EndInteract()

func EndInteract():
	hostNPC.lockdown = false
	overworld.camera.tempTarget = null
	overworld.player.EndInteract()
