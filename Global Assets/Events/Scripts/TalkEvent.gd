extends Event

@export var message:Message
@export var targetNPC:NPC

func InvokeEvent(target:NPC):
	#print("Sending Talk Signal")
	if targetNPC != null:
		target = targetNPC
	await get_tree().create_timer(startDelay).timeout
	EventBus.emit_signal("TalkNPC", target, self, message)
