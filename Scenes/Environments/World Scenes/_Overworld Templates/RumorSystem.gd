extends Node3D
class_name RumorSystem

@export var zoneMessages:Dictionary[Enums.ZoneTypes,Message]
#Replace with "character" arrays with their own message dicts, randomize char selection on call
@export var telltales:Array[NPC]
@export var tracks:Array[NPC]
@export var thresholds:Array[Threshold]

func _ready():
	await get_tree().create_timer(1.0).timeout
	for spawn in thresholds:
		spawn.AssignRumors()

#functions for clear and reset of telltales/tracks, as well as spawning across current district
#input faeble spawn(s) for the day, randomly determine threshold for each and assign tracks/telltales
