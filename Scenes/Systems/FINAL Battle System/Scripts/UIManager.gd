extends Node3D
class_name UIScene

@export var battleSystem:BattleSystemFINAL
var currentPlayer:BattlerData
var currentEnemy:BattlerData

var currentSwitch:int = -1 #input int, if same as before treat as confirmation


@export var pBookmark:UIElement
@export var eBookmark:UIElement
@export var commandBook:UIElement
var themeAnchor:Node3D
var attackButtons:Array[Node3D]
var attackThemes:Array[Label3D]
@export var rangefinder:UIElement
@export var partyMenu:UIElement

var currentIndex:int = 0

func _ready():
	#EventBus.connect("FaebleSwitched",FaebleChanged) #Send up to UI Subsequencer
	#EventBus.connect("FaebleFainted",FaebleFainted) #Use signal to tell to read action, detail, option from this
	currentPlayer = battleSystem.playerBattler
	currentEnemy = battleSystem.enemyBattler




func ShowUI(hideAll:bool=false):
	if hideAll:
		pBookmark.ShiftHide()
		eBookmark.ShiftHide()
		rangefinder.ShiftHide()
		partyMenu.ShiftHide()
		await commandBook.ShiftHide()
		for page in commandBook.commandPages:
			page.hide()
		commandBook.commandPages[0].show()
	else:
		pBookmark.ShiftShow()
		eBookmark.ShiftShow()
		rangefinder.ShiftShow()
		await commandBook.ShiftShow()
		


func TempSetup():
	commandBook.PopulateAttacks(currentPlayer)
	pass






func TacticsMenuButton(_viewport:Node,event:InputEvent,_event_position:Vector3,_normal:Vector3,_shape_idx:int,selection:int,selectDetail:int=-1):
	if !event.is_action_pressed("LeftMouse"):
		return
	match selection:
		0:#Back button
			selection = -1
			commandBook.commandPages[0].show()
			commandBook.commandPages[3].hide()
			return
		1: #Movement
			pass
			#option = selection-1
			#detail = selectDetail
			#battleSystem.Selection(battleSystem.playerBattler,action,option,detail)
			#THIS IS TEMPORARY UNTIL ENEMY BEHAVIOR DONE
			await get_tree().create_timer(0.5).timeout
			#battleSystem.Selection(battleSystem.enemyBattler,action,option,detail)
		2: #Switch
			pass
			#option = selection-1
			#await TempPrepSwitch()
		3: #Forfeit
			get_tree().quit() #VERY TEMP
	


#
#func PartyMenuButton(_viewport:Node, event:InputEvent, _event_position:Vector3, _normal:Vector3, _shape_idx:int, selection:int):
	#if !event.is_action_pressed("LeftMouse"):
		#return
	#var marks:Array = partyMenu.get_children()
	#var back:Node3D = marks.pop_front()
	#if selection == -1:
		#selection = -1
		#
		#for mark in marks:
			#mark.ShiftHide()
			#await get_tree().create_timer(0.1).timeout
		#await back.ShiftHide()
		#marks[currentSwitch].rotation_degrees = Vector3(0,0,0)
		#currentSwitch = -1
		#partyMenu.ShiftHide(0.1)
		#ShowUI()
		#commandPages[3].show()
		#commandPages[0].hide()
		#return
	#if selection != currentSwitch:
		#if currentSwitch != -1:
			#var altTween = get_tree().create_tween()
			#altTween.tween_property(marks[currentSwitch], "rotation_degrees", Vector3(0,0,0), 0.5)
			#await altTween.finished
			#dElements[Elements.bookmark].hide()
			#dElements[Elements.bookmark].reparent(back)
			#dElements[Elements.bookmark].position = Vector3(0,0,0)
			##await get_tree().create_timer(0.1).timeout
		#var tween = get_tree().create_tween()
		#dElements[Elements.bookmark].reparent(marks[selection])
		#dElements[Elements.bookmark].position = Vector3(0,0,0)
		#dElements[Elements.health].MaxHealthReset(currentPlayer.faebleTeam[selection].maxHP)
		#dElements[Elements.buildup].MaxBuildupReset(currentPlayer.faebleTeam[selection].maxBuildup)
		#dElements[Elements.nameplate].text = currentPlayer.faebleTeam[selection].name
		#if selection == 0:
			#dElements[Elements.health].SetHealthDisplay(
				#currentPlayer.instance.maxHP,
				#currentPlayer.health)
			#dElements[Elements.buildup].SetStatusDisplay(
				#currentPlayer.instance.maxBuildup,
				#currentPlayer.buildup,
				#currentPlayer.buildupTarget)
		#else:
			#dElements[Elements.health].SetHealthDisplay(
				#currentPlayer.faebleTeam[selection].maxHP,
				#currentPlayer.faebleTeam[selection].currentHP)
			#dElements[Elements.buildup].SetStatusDisplay(
				#currentPlayer.faebleTeam[selection].maxBuildup,
				#currentPlayer.faebleTeam[selection].currentBuildup,
				#currentPlayer.faebleTeam[selection].currentBuildupTarget)
		##dElements[Elements.status].text = ""
		#dElements[Elements.level].text = "Ch. " + str(currentPlayer.faebleTeam[selection].chapter) 
		#dElements[Elements.bookmark].show()
		#tween.tween_property(marks[selection], "rotation_degrees", Vector3(0,180,0), 0.5)
		#await tween.finished
		#currentSwitch = selection
	#elif selection == currentSwitch:
		#await marks[selection].ShiftHide()
		#await get_tree().create_timer(1).timeout
		#for mark in marks:
			#mark.ShiftHide()
			#await get_tree().create_timer(0.1).timeout
		#await back.ShiftHide()
		#marks[currentSwitch].rotation_degrees = Vector3(0,0,0)
		#currentSwitch = -1
		#partyMenu.ShiftHide(0.1)
		#detail = selection
		#if deathSwitch:
			#if playerSelect:
				#battleSystem.FaintSwitch(battleSystem.playerBattler,selection,queueSelect)
				#playerSelect = false
				#if queueSelect:
					#await get_tree().create_timer(0.5).timeout
					##await TempPrepSwitch()
					#queueSelect = false
				#else:
					#deathSwitch = false
				#return
			#if enemySelect:
				#battleSystem.FaintSwitch(battleSystem.enemyBattler,selection)
				#enemySelect = false
				#deathSwitch = false
				#return
		##battleSystem.Selection(battleSystem.playerBattler,action,option,detail)
		##THIS IS TEMPORARY UNTIL ENEMY BEHAVIOR DONE
		#await get_tree().create_timer(0.5).timeout
		##battleSystem.Selection(battleSystem.enemyBattler,action,option,detail)
		##await ShowUI()
	#pass
