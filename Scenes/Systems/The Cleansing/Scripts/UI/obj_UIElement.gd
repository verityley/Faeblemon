extends Node3D
class_name UIElement

@export var shiftSpeed:float = 0.5
@export var homeTarget:Vector3
@export var shiftTarget:Vector3
@export var blocker:Node3D
@export var blocked:bool
@export var hoverFX:Node3D
@export var interactArea:Area3D


func ShowHide(show:bool=false):
	BlockCheck()
	if show:
		show()
	else:
		hide()


func ShiftShow(altSpeed:float=-1.0):
	show()
	BlockCheck()
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	if altSpeed == -1.0:
		tween.tween_property(self, "position", homeTarget, shiftSpeed)
	else:
		tween.tween_property(self, "position", homeTarget, altSpeed)
	await tween.finished


func ShiftHide(altSpeed:float=-1.0):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	if altSpeed == -1.0:
		tween.tween_property(self, "position", shiftTarget, shiftSpeed)
	else:
		tween.tween_property(self, "position", shiftTarget, altSpeed)
	await tween.finished
	hide()


func BlockCheck():
	if blocked:
		if blocker == null:
			self.hide()
		else:
			blocker.show()
			interactArea.hide()
	else:
		if blocker == null:
			self.show()
		else:
			blocker.hide()
			interactArea.show()


func HoverCheck(exit:bool):
	if hoverFX != null:
		if exit:
			hoverFX.hide()
		else:
			hoverFX.show()
