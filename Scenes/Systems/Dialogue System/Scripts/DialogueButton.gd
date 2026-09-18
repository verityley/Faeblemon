extends Area3D

@export var bubble:int

func _mouse_enter():
	EventBus.TargetChoice.emit(true,bubble)

func _mouse_exit():
	EventBus.TargetChoice.emit(false,bubble)
