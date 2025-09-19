extends Node

@export var message:Message
@export var stage:Stage
@export var speaker:Speaker
@export var targetNPC:NPC

func InvokeEvent(target:NPC):
	if targetNPC != null:
		target = targetNPC
	EventBus.emit_signal("InterviewNPC", target, self, message, speaker, stage)
