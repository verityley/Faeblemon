extends Event

@export var team:Array[Faeble]
@export var stage:Stage
@export var targetNPC:NPC

func InvokeEvent(target:NPC):
	if targetNPC != null:
		target = targetNPC
	await get_tree().create_timer(startDelay).timeout
	EventBus.emit_signal("BattleNPC", target, self, team, stage)
