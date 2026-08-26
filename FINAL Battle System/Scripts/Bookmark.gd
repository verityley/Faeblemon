extends UIElement

@export var attached:BattlerData
@export var hpDisplay:HealthManager
@export var buildupDisplay:StatusManager
@export var statusLabel:Label3D

func _ready():
	EventBus.connect("HealthChanged", HealthChanged)
	EventBus.connect("BuildupChanged", BuildupChanged)
	EventBus.connect("StatusChanged", StatusChanged)

func HealthChanged(target:BattlerData, _amount:int=0):
	print("Changing 2D Health!")
	if target != attached:
		return
	#await ShiftShow()
	await get_tree().create_timer(0.5).timeout #TEMP
	hpDisplay.SetHealthDisplay(target.instance.maxHP,target.health)
	await get_tree().create_timer(1.0).timeout
	#ShiftHide()

func BuildupChanged(target:BattlerData, _amount:int, type:Enums.Status):
	print("Changing 2D Status!")
	if target != attached:
		return
	await ShiftShow()
	await get_tree().create_timer(0.5).timeout #TEMP
	buildupDisplay.SetStatusDisplay(target.instance.maxBuildup,target.buildup, type)
	var statusColor:Color
	match type:
		Enums.Status.Clear: statusColor = Color(1.0, 1.0, 1.0, 1.0)
		Enums.Status.Decay: statusColor = Color(0.72, 0.3, 1.0, 1.0)
		Enums.Status.Break: statusColor = Color(0.9, 0.491, 0.27, 1.0)
		Enums.Status.Fixate: statusColor = Color(1.0, 0.3, 1.0, 1.0)
		Enums.Status.Silence: statusColor = Color(0.3, 0.918, 1.0, 1.0)
		Enums.Status.Slow: statusColor = Color(0.3, 0.3, 1.0, 1.0)
	if target.buildup == target.instance.maxBuildup:
		statusLabel.modulate = statusColor
	elif target.buildup >= ceili(float(target.instance.maxBuildup)/2):
		statusLabel.modulate = (statusColor * Color(0.5, 0.5, 0.5, 1.0))
	else:
		statusLabel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	await get_tree().create_timer(1.0).timeout
	ShiftHide()

func StatusChanged(target:BattlerData,full:bool):
	if target != attached:
		return
	var statusText:String
	if full:
		match target.buildupTarget:
			Enums.Status.Decay: statusText = "Decay"
			Enums.Status.Break: statusText = "Fracture"
			Enums.Status.Fixate: statusText = "Fascinate"
			Enums.Status.Silence: statusText = "Silence"
			Enums.Status.Slow: statusText = "Stop"
	else:
		match target.buildupTarget:
			Enums.Status.Decay: statusText = "Blight"
			Enums.Status.Break: statusText = "Break"
			Enums.Status.Fixate: statusText = "Fixate"
			Enums.Status.Silence: statusText = "Hush"
			Enums.Status.Slow: statusText = "Slow"
	statusLabel.text = statusText
