extends Node
class_name Event
@export var startDelay:float = 0.01
@export var endDelay:float = 0.01
signal finished

func InvokeEvent(target:NPC):
	pass

func CompleteEvent():
	await get_tree().create_timer(endDelay).timeout
	emit_signal("finished")
