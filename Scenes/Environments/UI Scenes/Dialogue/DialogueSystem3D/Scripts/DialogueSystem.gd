extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func SendMessage():
	pass #Tell msg manager to create new bubble, fill in with information from convo manager
	#Then import speaker info and tell it to play anim

func PresentChoice():
	pass #If the message has a value for choices, then import from there. Otherwise present default y/n

func MessageSwitch():
	pass #Read message/conversation variables for any switch sets, then send info to Database
