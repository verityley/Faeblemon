extends Control

var nextScene = load("res://Scenes/Debug/DebugTeamSelector.tscn")

func _on_finish_pressed():
	#newFamiliar.currentHP = newFamiliar.maxHP
	var queueBattle:bool
	if get_child(0).isAlly == true:
		FaebleStorage.playerParty[0] = $BattleSimSelector.newFamiliar
		FaebleStorage.playerParty[1] = $BattleSimSelector2.newFamiliar
		queueBattle = false
	else:
		FaebleStorage.enemyParty[0] = $BattleSimSelector.newFamiliar
		FaebleStorage.enemyParty[1] = $BattleSimSelector2.newFamiliar
		queueBattle = true
	
	if queueBattle == true:
		nextScene = load("res://Scenes/Battle/BattleStage.tscn")
	var current = self
	var instance = nextScene.instantiate()
	get_tree().get_root().add_child(instance)
	#print(instance.get_child(0))
	if queueBattle == false:
		instance.get_child(0).isAlly = false
		instance.get_child(1).isAlly = false
		instance.get_child(0).Reinitialize()
		instance.get_child(1).Reinitialize()
	get_tree().get_root().remove_child(current)
	current.call_deferred("free")
	
	#newFamiliar.currentHP = newFamiliar.maxHP
	#FaebleStorage.playerParty[selectorIndex] = newFamiliar
	#nextScene = load("res://Scenes/Battle/BattleStage.tscn")
	#var current = self
	#var instance = nextScene.instantiate()
	#get_tree().get_root().add_child(instance)
	##instance.get_node("BattleManager").EnterBattle(PlayerParty.testBattler, PlayerParty.testOpponent)
	#instance.get_node("BattleManager").BattleSetup()
	#get_tree().get_root().remove_child(current)
	#current.call_deferred("free")
