extends MeshInstance3D

@export var distanceThreshold:float = 1.2
@export var hideDistance:float = -3.0
@export var showDistance:float = 1.288
@export var slideSpeed:float = 0.2
@export var player:Node3D


func _physics_process(delta: float):
	if player.global_position.z + distanceThreshold < global_position.z and position.y != hideDistance:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:y", hideDistance, slideSpeed)
		return
	elif player.global_position.z + distanceThreshold > global_position.z and position.y != showDistance:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:y", showDistance, slideSpeed)
		return
