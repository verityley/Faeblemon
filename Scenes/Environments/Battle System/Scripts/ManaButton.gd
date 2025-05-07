extends Area3D

@export var choice:int

func _mouse_enter():
	EventBus.TargetMana.emit(true,choice)

func _mouse_exit():
	EventBus.TargetMana.emit(false,choice)
