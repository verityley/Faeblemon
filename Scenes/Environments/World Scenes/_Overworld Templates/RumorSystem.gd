extends Node3D
class_name RumorSystem

@export var zoneMessages:Dictionary[Enums.ZoneTypes,Message]
#Replace with "character" arrays with their own message dicts, randomize char selection on call
@export var trackingPrefaces:Dictionary[Enums.ZoneTypes,Message]
@export var allTelltales:Array[NPC]
@export var allTracks:Array[NPC]
@export var allThresholds:Array[Threshold]
@export var rumorDifficulty:Array[Array] = [
	[2, 1, 3, 2, 1, 1, 1, 1, 1], #Easy
	[4, 1, 2, 2, 0, 0, 0, 1, 1], #Medium
	[5, 0, 2, 2], #Hard
	[3, 0, 2, 1] #Impossible
]
@onready var ananseed = preload("res://Database/Faebles/094Ananseed.tres")


#enum ZoneTypes{
	#Null=0,
	#Near,
	#Mid,
	#Far,
	#Onstreet,
	#Upstreet,
	#Downstreet,
	#Uphill,
	#Downhill,
#}

func _ready():
	await get_tree().create_timer(1.0).timeout
	NewSighting(ananseed, allThresholds[0], 0)

func NewSighting(encounter:Faeble, location:Threshold, difficulty:int):
	print("Generating New Sighting")
	var actionType:int = 0
	for action in rumorDifficulty[difficulty]:
		for i in range(action):
			if actionType == Enums.ZoneTypes.Null:
				location.AssignRumor(Enums.ZoneTypes.Far)
				pass #Landmarks - within far
			elif actionType == Enums.ZoneTypes.Near:
				var rumor:Message
				rumor = trackingPrefaces[Enums.ZoneTypes.Near].duplicate()
				var desc:String = encounter.trackDescriptions.pick_random()
				rumor.messageText += (" " + desc)
				location.AssignRumor(Enums.ZoneTypes.Near, rumor, true)
				pass #Near - tracks
			elif actionType == Enums.ZoneTypes.Mid:
				var rumor:Message
				rumor = trackingPrefaces[Enums.ZoneTypes.Mid].duplicate()
				var desc:String = encounter.trackDescriptions.pick_random()
				rumor.messageText += (" " + desc)
				location.AssignRumor(Enums.ZoneTypes.Mid, rumor, true, Enums.ZoneTypes.Near)
				pass #Mid - exclude Near - tracks
			elif actionType == Enums.ZoneTypes.Far:
				var rumor:Message
				rumor = trackingPrefaces[Enums.ZoneTypes.Far].duplicate()
				var desc:String = encounter.trackDescriptions.pick_random()
				rumor.messageText += (" " + desc)
				location.AssignRumor(Enums.ZoneTypes.Far, rumor, true, Enums.ZoneTypes.Mid)
				pass #Far - Exclude Mid - tracks
			#Add functionality here for other rumor zones as needed
		actionType += 1



#functions for clear and reset of telltales/tracks, as well as spawning across current district
#input faeble spawn(s) for the day, randomly determine threshold for each and assign tracks/telltales
