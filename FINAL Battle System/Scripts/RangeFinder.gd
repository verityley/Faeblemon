extends UIElement

var tempfix:bool=false

func _ready():
	EventBus.connect("FaebleMoved", DistanceChanged)

func DistanceChanged(rangeband:Enums.Ranges):
	await ShiftShow()
	var wheel:Sprite3D = get_child(0)
	var tween = get_tree().create_tween()
	var speed:float = 0.5
	match rangeband:
		Enums.Ranges.Melee:
			tween.tween_property(wheel, "rotation_degrees", Vector3(0,0,-45), speed)
		Enums.Ranges.Near:
			tween.tween_property(wheel, "rotation_degrees", Vector3(0,0,0), speed)
		Enums.Ranges.Far:
			tween.tween_property(wheel, "rotation_degrees", Vector3(0,0,45), speed)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	if tempfix == true:
		await ShiftHide()
	else:
		tempfix = true
