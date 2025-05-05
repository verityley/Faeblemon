extends Node3D

@onready var back: Node3D = $Back
@onready var commands: Node3D = $Commands




func Turn():
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(back, "rotation", Vector3(0,0,deg_to_rad(180)), 1.0)
	tween2.tween_property(commands, "rotation", Vector3(0,0,deg_to_rad(180)), 1.0)
