extends Node
var overworld:OverworldManager
@onready var hostNPC:NPC = get_parent()

@onready var preBattle: Node3D = $PreBattle
@onready var postBattle: Node3D = $PostBattle

func _ready() -> void:
	EventBus.connect("BattleNPC", Battle)

func PreBattle():
	for eventP:Event in preBattle.get_children():
		eventP.InvokeEvent(hostNPC)
		await eventP.finished

func Battle(npc:NPC, event:Event, team:Array[Faeble], stage:Stage):
	if npc != hostNPC:
		return
	await PreBattle()
	await overworld.NewBattle(team, stage)
	#await battle finished signal, return victory bool
	await overworld.UnloadInvestigation()
	await PostBattle(true) #replace true with victory bool
	event.CompleteEvent()

func PostBattle(victory:bool):
	if victory:
		for eventV in postBattle.get_child(0).get_children():
			eventV.InvokeEvent(hostNPC)
	else:
		for eventD in postBattle.get_child(1).get_children():
			eventD.InvokeEvent(hostNPC)
