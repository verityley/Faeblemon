extends Node3D
class_name UIScene

@export var battleSystem:BattleSystemFINAL
var currentPlayer:BattlerData
var currentEnemy:BattlerData
var deathSwitch:bool
var playerSelect:bool #TEMP
var enemySelect:bool #TEMP
var queueSelect:bool #TEMP
var currentSwitch:int = -1 #input int, if same as before treat as confirmation


enum Elements {
	bookmark=1,
	nameplate,
	health,
	level,
	buildup,
	status,
	buffs
}

@export var pElements:Dictionary[Elements,Node3D]
@export var eElements:Dictionary[Elements,Node3D]
@export var dElements:Dictionary[Elements,Node3D]
@export var commandBook:UIElement
var commandPages:Array[Node3D]
var themeAnchor:Node3D
var attackButtons:Array[Node3D]
var attackThemes:Array[Label3D]
@export var rangefinder:UIElement
@export var partyMenu:UIElement

var currentIndex:int = 0
var action:int = -1
var option:int = -1
var detail:int = -1

func _ready():
	for page in commandBook.get_children():
		commandPages.append(page)
	for button in commandPages[1].get_children():
		attackButtons.append(button)
	themeAnchor = attackButtons.pop_front().get_child(0)
	for mark in themeAnchor.get_children():
		attackThemes.append(mark.get_child(0))
	EventBus.connect("FaebleSwitched",FaebleChanged)
	EventBus.connect("FaebleFainted",FaebleFainted)
	currentPlayer = battleSystem.playerBattler
	currentEnemy = battleSystem.enemyBattler
	pElements[Elements.bookmark].attached = currentPlayer
	eElements[Elements.bookmark].attached = currentEnemy



func ShowUI(hideAll:bool=false):
	if hideAll:
		pElements[Elements.bookmark].ShiftHide()
		eElements[Elements.bookmark].ShiftHide()
		rangefinder.ShiftHide()
		partyMenu.ShiftHide()
		await commandBook.ShiftHide()
		for page in commandPages:
			page.hide()
		commandPages[0].show()
	else:
		pElements[Elements.bookmark].ShiftShow()
		eElements[Elements.bookmark].ShiftShow()
		rangefinder.ShiftShow()
		await commandBook.ShiftShow()
		


func TurnEnd():
	action = -1
	option = -1
	detail = -1
	#currentIndex = -1
	ShowUI(true)


func FaebleChanged(target:BattlerData):
	#print("Changing 2D Faeble!")
	if target == currentPlayer:
		pElements[Elements.health].MaxHealthReset(target.instance.maxHP)
		pElements[Elements.health].SetHealthDisplay(target.instance.maxHP, target.instance.currentHP)
		pElements[Elements.buildup].MaxBuildupReset(target.instance.maxBuildup)
		pElements[Elements.buildup].SetStatusDisplay(
			target.instance.maxBuildup,
			target.instance.currentBuildup,
			target.instance.currentBuildupTarget)
		#BuildupChanged(target)
		pElements[Elements.nameplate].text = target.instance.name
		pElements[Elements.status].text = ""
		pElements[Elements.level].text = "Ch. " + str(target.instance.chapter) 
		var i:int = 0
		for spell in attackButtons:
			if i == 0:
				i+=1
				continue
			if i == 4:
				break
			var nametag:Label3D = spell.get_child(1)
			nametag.text = target.instance.assignedSpells[i-1].name
			print("Changing Attack Name To: ",target.instance.assignedSpells[i-1].name)
			#Insert Graphic replacement here
			i+=1
		i=0
		for theme in attackThemes:
			var themeEffect:Label = theme.get_child(0)
			if i == 3:
				theme.text= target.instance.theme.name
				themeEffect.text = target.instance.theme.shortDesc
				break
			theme.text = battleSystem.playerWitch.assignedThemes[i].name
			themeEffect.text = battleSystem.playerWitch.assignedThemes[i].shortDesc
			i+=1
	elif target == currentEnemy:
		eElements[Elements.health].MaxHealthReset(target.instance.maxHP)
		eElements[Elements.health].SetHealthDisplay(target.instance.maxHP, target.instance.currentHP)
		eElements[Elements.buildup].MaxBuildupReset(target.instance.maxBuildup)
		eElements[Elements.buildup].SetStatusDisplay(
			target.instance.maxBuildup,
			target.instance.currentBuildup,
			target.instance.currentBuildupTarget)
		eElements[Elements.nameplate].text = target.instance.name
		#eElements[Elements.status].text = ""
		eElements[Elements.level].text = "Ch. " + str(target.instance.chapter) 
		#eElements[Elements.buildup].max_value = battleSystem.enemyBattler.instance.maxBuildup

func FaebleFainted(target:BattlerData):
	deathSwitch = true
	if target == battleSystem.playerBattler:
		playerSelect = true
		await TempPrepSwitch()
		print("Player Fainted, prompting UI")
	if target == battleSystem.enemyBattler:
		enemySelect = true
		await TempPrepSwitch()
		print("Enemy Fainted, prompting UI")
	if playerSelect and enemySelect:
		queueSelect = true
		print("Both Fainted, prompting queue")



func TopMenuButton(_viewport:Node, event:InputEvent, _event_position:Vector3, _normal:Vector3, _shape_idx:int, selection:int):
	if !event.is_action_pressed("LeftMouse"):
		return
	commandPages[0].hide()
	commandPages[selection].show()
	action = selection-1

func AttackMenuButton(_viewport:Node,event:InputEvent,_event_position:Vector3,_normal:Vector3,_shape_idx:int,selection:int,selectDetail:int=-1):
	if !event.is_action_pressed("LeftMouse"):
		return
	if selection == -1:#Input Theme detail
		detail = selectDetail
	elif selection == 0:#Back button
		selection = -1
		attackButtons[4].hide()
		commandPages[0].show()
		commandPages[1].hide()
		themeAnchor.hide()
		return
	elif selection == 4:#Send final selection to battle system
		attackButtons[4].hide()
		themeAnchor.hide()
		battleSystem.Selection(battleSystem.playerBattler,action,option,detail)
		#THIS IS TEMPORARY UNTIL ENEMY BEHAVIOR DONE
		await get_tree().create_timer(0.5).timeout
		battleSystem.Selection(battleSystem.enemyBattler,action,option,detail)
		TurnEnd()
	else:#Attack button selection
		option = selection-1
		attackButtons[4].show()
		if currentPlayer.bonded:
			themeAnchor.show()

func TacticsMenuButton(_viewport:Node,event:InputEvent,_event_position:Vector3,_normal:Vector3,_shape_idx:int,selection:int,selectDetail:int=-1):
	if !event.is_action_pressed("LeftMouse"):
		return
	match selection:
		0:#Back button
			selection = -1
			commandPages[0].show()
			commandPages[3].hide()
			return
		1: #Movement
			option = selection-1
			detail = selectDetail
			battleSystem.Selection(battleSystem.playerBattler,action,option,detail)
			#THIS IS TEMPORARY UNTIL ENEMY BEHAVIOR DONE
			await get_tree().create_timer(0.5).timeout
			battleSystem.Selection(battleSystem.enemyBattler,action,option,detail)
		2: #Switch
			option = selection-1
			await TempPrepSwitch()
		3: #Forfeit
			get_tree().quit() #VERY TEMP
	


func TempPrepSwitch():
	var textOut:String = "Summoned"
	var textKO:String = "Dispelled"
	await ShowUI(true)
	for mark in partyMenu.get_children():
		mark.ShiftHide(0.1)
	await get_tree().create_timer(0.1).timeout
	await partyMenu.ShiftShow(0.01)
	var i:int = -1
	for mark in partyMenu.get_children():
		if i == -1:
			if deathSwitch:
				mark.get_child(0).hide()
			else:
				mark.get_child(0).show()
			await mark.ShiftShow(1)
			i += 1
			continue
		if i == currentPlayer.faebleTeam.size():
			break
		var sprite:Sprite3D = mark.get_child(0).get_child(0)
		sprite.texture = currentPlayer.faebleTeam[i].sprite
		if currentPlayer.faebleTeam[i].fainted:
			mark.get_child(0).get_child(1).show()
			mark.get_child(0).get_child(1).get_child(0).text = textKO
			mark.get_child(1).hide()
			pass #Show blocker, hide area3d, set text
		elif i == 0:
			mark.get_child(0).get_child(1).show()
			if deathSwitch:
				mark.get_child(0).get_child(1).get_child(0).text = textKO
			else:
				mark.get_child(0).get_child(1).get_child(0).text = textOut
			mark.get_child(1).hide()
		else:
			mark.get_child(0).get_child(1).hide()
			mark.get_child(1).show()
		mark.ShiftShow()
		await get_tree().create_timer(0.1).timeout
		i += 1
	pass

func PartyMenuButton(_viewport:Node, event:InputEvent, _event_position:Vector3, _normal:Vector3, _shape_idx:int, selection:int):
	if !event.is_action_pressed("LeftMouse"):
		return
	var marks:Array = partyMenu.get_children()
	var back:Node3D = marks.pop_front()
	if selection == -1:
		selection = -1
		
		for mark in marks:
			mark.ShiftHide()
			await get_tree().create_timer(0.1).timeout
		await back.ShiftHide()
		marks[currentSwitch].rotation_degrees = Vector3(0,0,0)
		currentSwitch = -1
		partyMenu.ShiftHide(0.1)
		ShowUI()
		commandPages[3].show()
		commandPages[0].hide()
		return
	if selection != currentSwitch:
		if currentSwitch != -1:
			var altTween = get_tree().create_tween()
			altTween.tween_property(marks[currentSwitch], "rotation_degrees", Vector3(0,0,0), 0.5)
			await altTween.finished
			dElements[Elements.bookmark].hide()
			dElements[Elements.bookmark].reparent(back)
			dElements[Elements.bookmark].position = Vector3(0,0,0)
			#await get_tree().create_timer(0.1).timeout
		var tween = get_tree().create_tween()
		dElements[Elements.bookmark].reparent(marks[selection])
		dElements[Elements.bookmark].position = Vector3(0,0,0)
		dElements[Elements.health].MaxHealthReset(currentPlayer.faebleTeam[selection].maxHP)
		dElements[Elements.buildup].MaxBuildupReset(currentPlayer.faebleTeam[selection].maxBuildup)
		dElements[Elements.nameplate].text = currentPlayer.faebleTeam[selection].name
		if selection == 0:
			dElements[Elements.health].SetHealthDisplay(
				currentPlayer.instance.maxHP,
				currentPlayer.health)
			dElements[Elements.buildup].SetStatusDisplay(
				currentPlayer.instance.maxBuildup,
				currentPlayer.buildup,
				currentPlayer.buildupTarget)
		else:
			dElements[Elements.health].SetHealthDisplay(
				currentPlayer.faebleTeam[selection].maxHP,
				currentPlayer.faebleTeam[selection].currentHP)
			dElements[Elements.buildup].SetStatusDisplay(
				currentPlayer.faebleTeam[selection].maxBuildup,
				currentPlayer.faebleTeam[selection].currentBuildup,
				currentPlayer.faebleTeam[selection].currentBuildupTarget)
		#dElements[Elements.status].text = ""
		dElements[Elements.level].text = "Ch. " + str(currentPlayer.faebleTeam[selection].chapter) 
		dElements[Elements.bookmark].show()
		tween.tween_property(marks[selection], "rotation_degrees", Vector3(0,180,0), 0.5)
		await tween.finished
		currentSwitch = selection
	elif selection == currentSwitch:
		await marks[selection].ShiftHide()
		await get_tree().create_timer(1).timeout
		for mark in marks:
			mark.ShiftHide()
			await get_tree().create_timer(0.1).timeout
		await back.ShiftHide()
		marks[currentSwitch].rotation_degrees = Vector3(0,0,0)
		currentSwitch = -1
		partyMenu.ShiftHide(0.1)
		detail = selection
		if deathSwitch:
			if playerSelect:
				battleSystem.SelectBattler(battleSystem.playerBattler,selection,queueSelect)
				playerSelect = false
				if queueSelect:
					await get_tree().create_timer(0.5).timeout
					await TempPrepSwitch()
					queueSelect = false
				else:
					deathSwitch = false
				return
			if enemySelect:
				battleSystem.SelectBattler(battleSystem.enemyBattler,selection)
				enemySelect = false
				deathSwitch = false
				return
		battleSystem.Selection(battleSystem.playerBattler,action,option,detail)
		#THIS IS TEMPORARY UNTIL ENEMY BEHAVIOR DONE
		await get_tree().create_timer(0.5).timeout
		battleSystem.Selection(battleSystem.enemyBattler,action,option,detail)
		#await ShowUI()
	pass
