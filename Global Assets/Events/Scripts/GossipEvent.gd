extends Event

@export var message:Message
@export var targetNPC:NPC

func InvokeEvent(target:NPC):
	print("Sending Gossip Signal")
	if targetNPC != null:
		target = targetNPC
	await get_tree().create_timer(startDelay).timeout
	EventBus.emit_signal("GossipNPC", target, self, message)
