extends Node3D



func TurnCommands(main:bool):
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var back:Node3D = get_child(1)
	var commands:Node3D = get_child(2)
	if main:
		tween.tween_property(back, "rotation", Vector3(0,0,deg_to_rad(0)), 1.0)
		tween2.tween_property(commands, "rotation", Vector3(0,0,deg_to_rad(0)), 1.0)
	else:
		tween.tween_property(back, "rotation", Vector3(0,0,deg_to_rad(180)), 1.0)
		tween2.tween_property(commands, "rotation", Vector3(0,0,deg_to_rad(180)), 1.0)
	await tween.finished
