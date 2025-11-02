extends Node
var overworld:OverworldManager
@onready var hostNPC:NPC = get_parent()

@onready var preInterview: Node = $PreInterview
@onready var postInterview: Node = $PostInterview


func _ready() -> void:
	EventBus.connect("InterviewNPC", Interview)

func PreInterview():
	for eventPre:Event in preInterview.get_children():
		eventPre.InvokeEvent(hostNPC)
		await eventPre.finished

func Interview(npc:NPC, event:Event, message:Message, speaker:Speaker, stage:Stage):
	if npc != hostNPC:
		return
	await PreInterview()
	await overworld.NewInterview(message, speaker, stage)
	#await battle finished signal, return victory bool
	await overworld.UnloadInvestigation()
	await PostInterview()
	event.CompleteEvent()

func PostInterview():
	for eventPost in postInterview.get_children():
		eventPost.InvokeEvent(hostNPC)
