extends Node3D

#@export var overworld:OverworldManager
@onready var hostNPC:NPC = get_parent()
@onready var events: Node = $Events


func _ready() -> void:
	EventBus.connect("PassbyNPC", Passby)

func Passby(npc:NPC):
	if npc != hostNPC:
		#print("Not for me!")
		return
	#print("Received Passby Signal")
	#EventBus.emit_signal("CancelEvents", hostNPC)
	for event:Event in events.get_children():
		event.InvokeEvent(hostNPC)
		await event.finished
		print("Event Finished")
	print("All Events Finished")

func EndPassby(npc:NPC):
	pass
