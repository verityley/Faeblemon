extends Node3D

@onready var back: Node3D = $Back
@onready var commands: Node3D = $Commands




func Turn(main:bool):
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	if main:
		tween.tween_property(back, "rotation", Vector3(0,0,deg_to_rad(0)), 1.0)
		tween2.tween_property(commands, "rotation", Vector3(0,0,deg_to_rad(0)), 1.0)
	else:
		tween.tween_property(back, "rotation", Vector3(0,0,deg_to_rad(180)), 1.0)
		tween2.tween_property(commands, "rotation", Vector3(0,0,deg_to_rad(180)), 1.0)
	await tween.finished
