extends SpotLight3D

@export var target:Node3D
@export var offset:Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(target.global_position + offset)
