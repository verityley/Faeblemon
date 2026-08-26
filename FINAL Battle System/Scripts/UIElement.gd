extends Node3D
class_name UIElement

@export var shiftSpeed:float = 0.5
@export var homeTarget:Vector3
@export var shiftTarget:Vector3


func ShiftShow(altSpeed:float=-1.0):
	show()
	var tween = get_tree().create_tween()
	if altSpeed == -1.0:
		tween.tween_property(self, "position", homeTarget, shiftSpeed)
	else:
		tween.tween_property(self, "position", homeTarget, altSpeed)
	await tween.finished


func ShiftHide(altSpeed:float=-1.0):
	var tween = get_tree().create_tween()
	if altSpeed == -1.0:
		tween.tween_property(self, "position", shiftTarget, shiftSpeed)
	else:
		tween.tween_property(self, "position", shiftTarget, altSpeed)
	await tween.finished
	hide()
