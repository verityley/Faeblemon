extends Area3D
#VERY TEMPORARY, eventually will move these all to relevant triggers rather than all on one
@export var overworld:OverworldManager
@export var stage:Stage
@export var battle:bool
@export var witchBattle:bool
@export var witchEncounter:Witch
@export var wildEncounter:Faeble
@export var dialogue:bool
@export var conversation:Conversation

func LoadIScene(_body):
	overworld.LoadInvestigation(stage)
	await get_tree().create_timer(3.5).timeout
	overworld.UnloadInvestigation()
