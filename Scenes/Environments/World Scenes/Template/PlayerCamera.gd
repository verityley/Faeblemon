extends Camera3D

@export var camTarget:Node3D
@export var camSpeed:float
@export var camOffset:Vector3 = Vector3(0, 0.75, 3)

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, camTarget.global_position + camOffset, camSpeed)
