extends Area3D

@export var choice:int
@export var stage:int

func _mouse_enter():
	EventBus.TargetBattle.emit(true,choice,stage)

func _mouse_exit():
	EventBus.TargetBattle.emit(false,choice,stage)
