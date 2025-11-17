extends Control

@export var battleSystem:BattleSystemFINAL
@onready var state_label: Label = $StateLabel

var menuLayer:int = -1
var option:int = -1
var detail:int = -1

func _ready():
	EventBus.connect("BattleStateChanged", StateChanged)

func StateChanged(state:int):
	state_label.text = battleSystem.BattleSteps.keys()[state]
