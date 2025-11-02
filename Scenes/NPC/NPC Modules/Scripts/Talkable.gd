extends Node3D
@onready var hostNPC:NPC = get_parent()

@export var dialogueSystem:ChatterSystem

func _ready() -> void:
	EventBus.connect("TalkNPC", Talk)

func Talk(npc:NPC, event:Event, message:Message):
	if npc != hostNPC:
		#print("Not for me!")
		return
	print("Received Talk Signal")
	dialogueSystem.talking = true
	dialogueSystem.NewMessage(message)
	await dialogueSystem.finished
	print("Talk Event Finished")
	dialogueSystem.talking = false
	event.CompleteEvent()
