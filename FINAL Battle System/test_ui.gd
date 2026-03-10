extends Control

@export var battleSystem:BattleSystemFINAL
@onready var state_label: Label = $StateLabel
@onready var distance_amount: Label = $DistanceLabel/DistanceAmount
@onready var enemyHealth: ProgressBar = $EnemyUI/ProgressBar
@onready var playerHealth: ProgressBar = $PlayerUI/ProgressBar
@onready var enemyStatus: ProgressBar = $EnemyUI/StatusBar
@onready var playerStatus: ProgressBar = $PlayerUI/StatusBar
@onready var eStatusLabel: Label = $EnemyUI/StatusLabel
@onready var pStatusLabel: Label = $PlayerUI/StatusLabel


var action:int = -1
var option:int = -1
var detail:int = -1

func _ready():
	EventBus.connect("BattleStateChanged", StateChanged)
	EventBus.connect("HealthChanged", HealthChanged)
	EventBus.connect("BuildupChanged", BuildupChanged)
	EventBus.connect("FaebleMoved", DistanceChanged)
	EventBus.connect("BattleStart",BattleStart)
	EventBus.connect("StatusChanged",StatusChanged)
	playerStatus.add_theme_stylebox_override("fill",playerStatus.get_theme_stylebox("fill").duplicate())
	enemyStatus.add_theme_stylebox_override("fill",enemyStatus.get_theme_stylebox("fill").duplicate())

func BattleStart():
	playerHealth.max_value = battleSystem.playerBattler.instance.maxHP
	enemyHealth.max_value = battleSystem.enemyBattler.instance.maxHP
	playerStatus.max_value = battleSystem.playerBattler.instance.maxBuildup
	enemyStatus.max_value = battleSystem.enemyBattler.instance.maxBuildup

func StateChanged(state:int):
	state_label.text = battleSystem.BattleSteps.keys()[state]
	if state == battleSystem.BattleSteps.Recycle:
		action = -1
		option = -1
		detail = -1

func HealthChanged(target:BattlerData):
	print("Changing Health!")
	if target == battleSystem.playerBattler:
		playerHealth.value = target.health
	elif target == battleSystem.enemyBattler:
		enemyHealth.value = target.health

func BuildupChanged(target:BattlerData):
	print("Changing Buildup!")
	var statusColor:Color
	match target.buildupTarget:
		Enums.Status.Clear: statusColor = Color(1.0, 1.0, 1.0, 1.0)
		Enums.Status.Decay: statusColor = Color(0.608, 0.0, 1.0, 1.0)
		Enums.Status.Break: statusColor = Color(0.608, 0.0, 0.0, 1.0)
		Enums.Status.Fixate: statusColor = Color(1.0, 0.0, 1.0, 1.0)
		Enums.Status.Silence: statusColor = Color(0.0, 0.518, 0.584, 1.0)
		Enums.Status.Slow: statusColor = Color(0.0, 0.0, 1.0, 1.0)
	if target == battleSystem.playerBattler:
		playerStatus.value = target.buildup
		playerStatus.get("theme_override_styles/fill").bg_color = statusColor
	elif target == battleSystem.enemyBattler:
		enemyStatus.value = target.buildup
		enemyStatus.get("theme_override_styles/fill").bg_color = statusColor

func StatusChanged(target:BattlerData, full:bool):
	prints("Changing Status!",Enums.Status.keys()[target.buildupTarget])
	if target == battleSystem.playerBattler:
		pStatusLabel.text = Enums.Status.keys()[target.buildupTarget]
	elif target == battleSystem.enemyBattler:
		eStatusLabel.text = Enums.Status.keys()[target.buildupTarget]
	var statusColor:Color
	if full:
		match target.status:
			Enums.Status.Clear: statusColor = Color(1.0, 1.0, 1.0, 1.0)
			Enums.Status.Decay: statusColor = Color(0.608, 0.0, 1.0, 1.0)
			Enums.Status.Break: statusColor = Color(0.608, 0.0, 0.0, 1.0)
			Enums.Status.Fixate: statusColor = Color(1.0, 0.0, 1.0, 1.0)
			Enums.Status.Silence: statusColor = Color(0.0, 0.518, 0.584, 1.0)
			Enums.Status.Slow: statusColor = Color(0.0, 0.0, 1.0, 1.0)
		if target == battleSystem.playerBattler:
			pStatusLabel.add_theme_color_override("font_color",statusColor)
		elif target == battleSystem.enemyBattler:
			eStatusLabel.add_theme_color_override("font_color",statusColor)


func DistanceChanged(range:Enums.Ranges):
	print("Changing Distance!")
	distance_amount.text = Enums.Ranges.keys()[range]

func _on_attack_button_down(attack: int) -> void:
	option = attack
	pass # Replace with function body.


func _on_theme_button_down(theme: int) -> void:
	detail = theme
	if option != -1:
		battleSystem.Selection(battleSystem.playerBattler,action,option,detail)
		await get_tree().create_timer(0.5).timeout
		battleSystem.Selection(battleSystem.enemyBattler,action,option,detail)
		action = -1
		option = -1
		detail = -1
	pass # Replace with function body.


func _on_action_button_button_down(button: int) -> void:
	action = button
	pass # Replace with function body.
