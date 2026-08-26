extends Node2D
class_name BattleScene2D

@export var battleSystem:BattleSystemFINAL
var currentPlayer:BattlerData
var currentEnemy:BattlerData

@export var rangefinder:Node2D

enum Elements {
	bookmark=1,
	nameplate,
	health,
	level,
	buildup,
	status,
	buffs
}

@export var pElements:Dictionary[Elements,Node]
@export var eElements:Dictionary[Elements,Node]
@export var commandBook:Node2D
var commandPages:Array[Node2D]
var themeAnchor:Node2D
var attackButtons:Array[Node2D]
var attackThemes:Array[Label]

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
	#await ShowUI(true)
	#EventBus.connect("BattleStart",BattleStart)
	EventBus.connect("TurnStart", TurnStart)
	#EventBus.connect("TurnEnd", TurnEnd)
	EventBus.connect("BattleStateChanged", StateChanged)
	EventBus.connect("HealthChanged", HealthChanged)
	EventBus.connect("BuildupChanged", BuildupChanged)
	EventBus.connect("FaebleMoved", DistanceChanged)
	EventBus.connect("FaebleSwitched",FaebleChanged)
	#EventBus.connect("StatusChanged",StatusChanged)
	#EventBus.connect("FaebleFainted",FaebleFainted)
	currentPlayer = battleSystem.playerBattler
	currentEnemy = battleSystem.enemyBattler
	pElements[Elements.buildup].add_theme_stylebox_override("fill",
	pElements[Elements.buildup].get_theme_stylebox("fill").duplicate())
	#eElements[Elements.buildup].add_theme_stylebox_override("fill",
	#eElements[Elements.buildup].get_theme_stylebox("fill").duplicate())
	#ShowUI()


func ShowUI(hideAll:bool=false):
	var tweenBook = get_tree().create_tween()
	var tweenPlayer = get_tree().create_tween()
	var tweenEnemy = get_tree().create_tween()
	var pMark:Node2D = pElements[Elements.bookmark]
	var eMark:Node2D = eElements[Elements.bookmark]
	var speed:float = 0.5
	if hideAll:
		tweenBook.tween_property(commandBook, "position", Vector2(960,1300), speed)
		tweenPlayer.tween_property(pMark, "position", Vector2(-170,260), speed)
		tweenEnemy.tween_property(eMark, "position", Vector2(2050,431), speed)
		await tweenBook.finished
		pMark.hide()
		eMark.hide()
		for page in commandPages:
			page.hide()
		commandPages[0].show()
		commandBook.hide()
		return
	commandBook.show()
	pMark.show()
	eMark.show()
	tweenBook.tween_property(commandBook, "position", Vector2(960,840), speed)
	tweenPlayer.tween_property(pMark, "position", Vector2(179,260), speed)
	tweenEnemy.tween_property(eMark, "position", Vector2(1704,431), speed)


func BattleStart():
	#currentPlayer = battleSystem.playerBattler
	#pElements[Elements.health].MaxHealthReset(currentPlayer.instance.maxHP)
	#currentEnemy = battleSystem.enemyBattler
	#eElements[Elements.health].MaxHealthReset(currentEnemy.instance.maxHP)
	pass

func TurnStart():
	#attackTree[0].show()
	#witchTree[0].show()
	#tacticsTree[0].show()
	ShowUI()
	#currentIndex = 0

func TurnEnd():
	action = -1
	option = -1
	detail = -1
	#currentIndex = -1
	ShowUI(true)


func HealthChanged(target:BattlerData, _amount:int=0):
	print("Changing 2D Health!")
	if target == battleSystem.playerBattler:
		var tween = get_tree().create_tween()
		var speed:float = 0.5
		var mark:Node2D = pElements[Elements.bookmark]
		mark.show()
		tween.tween_property(mark, "position", Vector2(179,260), speed)
		await tween.finished
		await get_tree().create_timer(0.5).timeout #TEMP
		pElements[Elements.health].SetHealthDisplay(target.instance.maxHP,target.health)
		await get_tree().create_timer(1.0).timeout
		tween = get_tree().create_tween()
		tween.tween_property(mark, "position", Vector2(-170,260), speed)
		await tween.finished
		mark.hide()
		
	elif target == battleSystem.enemyBattler:
		var tween = get_tree().create_tween()
		var speed:float = 0.5
		var mark:Node2D = eElements[Elements.bookmark]
		mark.show()
		tween.tween_property(mark, "position", Vector2(1704,431), speed)
		await tween.finished
		await get_tree().create_timer(0.5).timeout #TEMP
		eElements[Elements.health].SetHealthDisplay(target.instance.maxHP,target.health)
		await get_tree().create_timer(1.0).timeout
		tween = get_tree().create_tween()
		tween.tween_property(mark, "position", Vector2(2050,431), speed)
		await tween.finished
		mark.hide()
		

func BuildupChanged(target:BattlerData, amount:int=0, type:int=0):
	#print("Changing 2D Buildup!")
	var statusColor:Color
	match target.buildupTarget:
		Enums.Status.Clear: statusColor = Color(1.0, 1.0, 1.0, 1.0)
		Enums.Status.Decay: statusColor = Color(0.718, 0.35, 1.0, 1.0)
		Enums.Status.Break: statusColor = Color(1.0, 0.491, 0.35, 1.0)
		Enums.Status.Fixate: statusColor = Color(1.0, 0.35, 0.74, 1.0)
		Enums.Status.Silence: statusColor = Color(0.35, 1.0, 0.935, 1.0)
		Enums.Status.Slow: statusColor = Color(0.35, 0.523, 1.0, 1.0)
	if target == battleSystem.playerBattler:
		pElements[Elements.buildup].value = target.buildup
		pElements[Elements.buildup].get("theme_override_styles/fill").bg_color = statusColor
	#elif target == battleSystem.enemyBattler:
		#eElements[Elements.buildup].value = target.buildup
		#eElements[Elements.buildup].get("theme_override_styles/fill").bg_color = statusColor

func FaebleChanged(target:BattlerData):
	#print("Changing 2D Faeble!")
	if target == currentPlayer:
		pElements[Elements.health].MaxHealthReset(target.instance.maxHP)
		#HealthChanged(target)
		pElements[Elements.buildup].max_value = target.instance.maxBuildup
		BuildupChanged(target)
		pElements[Elements.nameplate].text = target.instance.name
		pElements[Elements.level].text = "Ch. " + str(target.instance.chapter) 
		var i:int = 0
		for spell in attackButtons:
			if i == 0:
				i+=1
				continue
			if i == 4:
				break
			var nametag:Label = spell.get_child(1)
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
		#HealthChanged(target)
		eElements[Elements.nameplate].text = target.instance.name
		eElements[Elements.level].text = "Ch. " + str(target.instance.chapter) 
		#eElements[Elements.buildup].max_value = battleSystem.enemyBattler.instance.maxBuildup

func DistanceChanged(range:Enums.Ranges):
	var wheel:Sprite2D = rangefinder.get_child(0)
	var tween = get_tree().create_tween()
	var speed:float = 0.5
	match range:
		Enums.Ranges.Melee:
			tween.tween_property(wheel, "rotation", deg_to_rad(45), speed)
		Enums.Ranges.Near:
			tween.tween_property(wheel, "rotation", deg_to_rad(0), speed)
		Enums.Ranges.Far:
			tween.tween_property(wheel, "rotation", deg_to_rad(-45), speed)

func StateChanged(state:int):
	#print("Changing 2D State! State: ",state)
	#await get_tree().create_timer(0.3).timeout
	match state:
		battleSystem.BattleSteps.Startup:
			pass
		
		battleSystem.BattleSteps.ActionSelect:
			ShowUI()
		
		battleSystem.BattleSteps.RoundStart:
			ShowUI(true)
		
		battleSystem.BattleSteps.BeforeAll:
			pass
		
		battleSystem.BattleSteps.BeforeAction:
			pass
		
		battleSystem.BattleSteps.DuringAction:
			pass
		
		battleSystem.BattleSteps.AfterAction:
			pass
		
		battleSystem.BattleSteps.AfterAll:
			pass
		
		battleSystem.BattleSteps.Switch:
			pass
		
		battleSystem.BattleSteps.Recycle:
			pass

func TopMenuButton(_viewport: Node, event: InputEvent, _shape_idx: int, selection:int):
	if !event.is_action_pressed("LeftMouse"):
		return
	commandPages[0].hide()
	commandPages[selection].show()
	action = selection-1

func AttackMenuButton(_viewport: Node, event: InputEvent, _shape_idx: int, selection:int, selectDetail:int=-1):
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
