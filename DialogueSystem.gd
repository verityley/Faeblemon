extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



#Check next nonskippable message in conversation array
#Create new text bubble at y + viewport height - textbox height + margin size
#Iterate through array of prior messages, moving them up by textbox height
#Save new message to message history
