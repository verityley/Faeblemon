extends Camera3D

var anchor:Vector3
var currentCam:int=0
@export var UICam:Camera3D

func _process(_delta: float):
	UICam.global_position = global_position

func ChangeCam(actor:int, speed:float, reset:bool=false):
	var target:Vector3 = position
	if currentCam == actor:
		return
	else:
		currentCam = actor
	#var range
	match actor:
		-1:
			target = anchor
		0:
			target.x = 0
			target.y = 0
			target.z = 20
		Enums.Actors.pFaeble:
			target.x = -2
			target.y = -0.2
			target.z = 18
			#stageSystem.LayerShifting(-0.1, 0.1, speed, -0.5)
		Enums.Actors.pWitch:
			target.x = -5
			target.y = -0.4
			target.z = 19
			#stageSystem.LayerShifting(-0.2, 0.1, speed, -1.5)
		Enums.Actors.eFaeble:
			target.x = 2
			target.y = 0.2
			target.z = 15
			#stageSystem.LayerShifting(-0.1, -0.1, speed, 0.5)
		Enums.Actors.eWitch:
			target.x = 3
			target.y = 0.4
			target.z = 14
			#stageSystem.LayerShifting(-0.2, -0.1, speed, 1.0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target, speed)
