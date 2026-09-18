extends Node
@export var battleSystem:BattleSystemFINAL
@export var scene3D:BattleActors
@export var sceneUI:UIScene

func _ready():
	EventBus.connect("BattleStateChanged", StateChanged)
	sceneUI.commandBook.connect("Select",SelectBroadcast)
	await get_tree().create_timer(0.3).timeout
	Begin()

func Begin():
	battleSystem.PrimeParties()
	scene3D.ActorSetup()
	print("Test")
	await get_tree().create_timer(0.3).timeout
	sceneUI.ShowUI(true)
	await scene3D.actors[scene3D.Actors.stage].LoadScene(scene3D.actors[scene3D.Actors.stage].stageResource, 1)
	await battleSystem.SetupBattle()
	sceneUI.TempSetup()

func SelectBroadcast(action:int, option:int, detail:int):
	EventBus.emit_signal("Selection",true,action,option,detail)
	await get_tree().create_timer(0.3).timeout
	EventBus.emit_signal("Selection",false,action,option,detail)

func StateChanged(state:int):
	print("Changing State! State: ",battleSystem.BattleSteps.keys()[state])
	await get_tree().create_timer(0.1).timeout
	match state:
		battleSystem.BattleSteps.Startup:
			await scene3D.actors[scene3D.Actors.camera].ChangeCam(scene3D.Actors.reset, 0.5)
			EventBus.emit_signal("NextStep")
			pass #Move 3D cam to overview
		
		battleSystem.BattleSteps.ActionSelect:
			await sceneUI.ShowUI()
			#EventBus.emit_signal("NextStep")
			pass #Show 2D UI
		
		battleSystem.BattleSteps.RoundStart:
			await get_tree().create_timer(0.5).timeout
			sceneUI.ShowUI(true)
			await scene3D.actors[scene3D.Actors.camera].ChangeCam(scene3D.Actors.stage, 1.0)
			EventBus.emit_signal("NextStep")
			pass #Hide 2D UI, move 3D cam to battle view
		
		battleSystem.BattleSteps.BeforeAll:
			EventBus.emit_signal("NextStep")
			pass
		
		battleSystem.BattleSteps.BeforeAction:
			var target:BattlerData = battleSystem.currentOrder[battleSystem.currentIndex]
			if target.fainted:
				await get_tree().create_timer(0.2).timeout
				EventBus.emit_signal("NextStep")
				return
			await get_tree().create_timer(1.5).timeout
			if target == battleSystem.playerBattler:
				await scene3D.actors[scene3D.Actors.camera].ChangeCam(scene3D.Actors.pFaeble, 0.5)
			elif target == battleSystem.enemyBattler:
				await scene3D.actors[scene3D.Actors.camera].ChangeCam(scene3D.Actors.eFaeble, 0.5)
			await get_tree().create_timer(1.0).timeout
			EventBus.emit_signal("NextStep")
			pass #Change cam to faeble, show action name
		
		battleSystem.BattleSteps.DuringAction:
			await get_tree().create_timer(1.0).timeout
			var target:BattlerData = battleSystem.currentOrder[battleSystem.currentIndex]
			if target.fainted:
				await get_tree().create_timer(0.2).timeout
				EventBus.emit_signal("NextStep")
				return
			#await get_tree().create_timer(1.5).timeout
			if target == battleSystem.playerBattler:
				await scene3D.actors[scene3D.Actors.pFaeble].MoveBy(Vector3(1,0,0),true, 0.1)
				await scene3D.actors[scene3D.Actors.camera].ChangeCam(scene3D.Actors.eFaeble, 0.5)
			elif target == battleSystem.enemyBattler:
				await scene3D.actors[scene3D.Actors.eFaeble].MoveBy(Vector3(-1,0,0),true, 0.1)
				await scene3D.actors[scene3D.Actors.camera].ChangeCam(scene3D.Actors.pFaeble, 0.5)
			await get_tree().create_timer(0.5).timeout
			EventBus.emit_signal("NextStep")
			pass #Activate attack anim, anim cam movement
		
		battleSystem.BattleSteps.AfterAction:
			await get_tree().create_timer(1.0).timeout
			await scene3D.actors[scene3D.Actors.camera].ChangeCam(scene3D.Actors.stage, 1.0)
			await get_tree().create_timer(0.5).timeout
			EventBus.emit_signal("NextStep")
			if battleSystem.currentOrder[battleSystem.currentIndex].switching:
				await get_tree().create_timer(1.0).timeout
			pass #Reset camera to field
		
		battleSystem.BattleSteps.AfterAll:
			EventBus.emit_signal("NextStep")
			pass #Aura messages, decay anims
		
		battleSystem.BattleSteps.Switch:
			EventBus.emit_signal("NextStep")
			pass #Bring up switch menus
		
		battleSystem.BattleSteps.Recycle:
			EventBus.emit_signal("NextStep")
			pass #ensure all menus are closed
