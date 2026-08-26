extends Node3D

@export var attached:BattlerData
@export var shiftSpeed:float = 0.5
@export var homeTarget:Vector3
@export var shiftTarget:Vector3
@export var rangeTargets:Dictionary[Enums.Ranges,Vector3]


func _ready():
	EventBus.connect("FaebleSwitched",SwitchFaeble)
	EventBus.connect("FaebleMoved",FaebleMoved)


func MoveTo(location:Vector3, altSpeed:float=-1.0):
	var speed:float
	if altSpeed != -1.0:
		speed = altSpeed
	else:
		speed = shiftSpeed
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", location, speed)
	await tween.finished

func MoveBy(motion:Vector3, bounceback:bool=false, altSpeed:float=-1.0):
	var speed:float
	if altSpeed != -1.0:
		speed = altSpeed
	else:
		speed = shiftSpeed
	var origin:Vector3 = position
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", origin + motion, speed)
	if bounceback:
		tween.tween_property(self, "position", origin, speed)
	await tween.finished

func SwitchFaeble(target:BattlerData):
	if target != attached:
		print("Signal not for me! (Faeble Change)")
		return #This signal is not for me
	await MoveTo(shiftTarget, 1)
	var faebleMesh:MeshInstance3D = get_child(0)
	var entry:Faeble = target.instance
	var texture:Material
	hide()
	texture = faebleMesh.get_surface_override_material(0)
	texture.albedo_texture = entry.sprite
	faebleMesh.set_surface_override_material(0, texture)
	faebleMesh.position = entry.groundOffset
	faebleMesh.scale = entry.battlerScale
	await get_tree().create_timer(0.5).timeout
	show()
	await MoveTo(homeTarget, 1)


func FaebleMoved(band:Enums.Ranges):
	var tween = get_tree().create_tween()
	homeTarget = rangeTargets[band]
	tween.tween_property(self, "position", rangeTargets[band], shiftSpeed)
	await tween.finished
