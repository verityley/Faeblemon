extends Node
@export var codex:Dictionary

@export var playerParty:Array[Faeble]
@export var maxPartySize:int = 6

@export var playerStorage:Array[Faeble]

@export var enemyParty:Array[Faeble] #This is a holdover variable, might go unused

# Called when the node enters the scene tree for the first time.
func _ready():
	#TEMP
	var index:int = 0
	for faeble in playerParty:
		if faeble == null:
			index += 1
			continue
		print("Creating party instance of ", faeble.name)
		var faebleInstance = FaebleCreation.CreateFaeble(faeble, 4)
		playerParty[index] = faebleInstance
		index += 1 
	pass # Replace with function body.


func AddToParty(faebleInstance:Faeble):
	if playerParty.size() >= maxPartySize:
		print("Party too full, give choice to swap and send one to storage.")
	else:
		pass
