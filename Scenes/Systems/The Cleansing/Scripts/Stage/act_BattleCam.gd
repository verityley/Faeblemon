extends Camera3D

var anchor:Vector3
var currentCam:int=-1
@export var camPositions:Dictionary[Actors,Vector3]


enum Actors {
	reset=-1,
	stage=0,
	pFaeble=1,
	pWitch,
	pUI,
	eFaeble,
	eWitch,
	eUI,
	camera,
	commands
}


func ChangeCam(actor:int, speed:float, reset:bool=false):
	var target:Vector3 = position
	if currentCam == actor:
		return
	else:
		currentCam = actor
	#var range
	if actor == -1: target = anchor
	else: target = camPositions[actor]
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", target, speed)
