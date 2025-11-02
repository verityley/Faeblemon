extends Node3D
@onready var hostNPC:NPC = get_parent()

@export var dialogueSystem:GossipSystem

func _ready() -> void:
	EventBus.connect("GossipNPC", Gossip)
	EventBus.connect("CancelEvents", Cancel)

func Gossip(npc:NPC, event:Event, message:Message):
	if npc != hostNPC:
		#print("Not for me!")
		return
	print("Received Gossip Signal")
	event.CompleteEvent()
	if message == null:
		print("Error! No message or rumor present.")
		return
	dialogueSystem.NewMessage(message)

func Cancel(npc:NPC):
	if npc != hostNPC:
		#print("Not for me!")
		return
	print("Canceling Current Gossip")
	dialogueSystem.ClearMessage()
