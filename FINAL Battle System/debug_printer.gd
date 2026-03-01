extends Node


func _ready():
	EventBus.connect("BattlePrint", BattleMessage)

func BattleMessage(message:String):
	print(message)
