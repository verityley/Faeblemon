extends Node

@export var playerParty:Array[Faeble]
@export var maxPartySize:int = 6

@export var playerStorage:Array[Faeble]

@export var enemyParty:Array[Faeble] #This is a holdover variable, might go unused

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func AddToParty(faebleInstance:Faeble):
	if playerParty.size() >= maxPartySize:
		print("Party too full, give choice to swap and send one to storage.")
	else:
		pass
