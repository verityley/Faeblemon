extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func StartConversation():
	pass #Initialize conversation tree flow, and set convo to beginning

func ProgressConversation():
	pass #Send conversation index down to next message, if no choice or branch present
	#If variable sent to function, use to determine branch progression
	#Search Dictionary for Label, using GoToLabel value

func FinishConversation():
	pass #Unload conversation variables and reset for next.
