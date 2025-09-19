extends Camera3D

@export var tempTarget:Node3D
@export var camTarget:Node3D
@export var camSpeed:float
@export var camOffset:Vector3 = Vector3(0, 0.75, 3)

func _physics_process(delta: float) -> void:
	if tempTarget == null:
		global_position = lerp(global_position, camTarget.global_position + camOffset, camSpeed)
	else:
		global_position = lerp(global_position, tempTarget.global_position + camOffset, camSpeed)
