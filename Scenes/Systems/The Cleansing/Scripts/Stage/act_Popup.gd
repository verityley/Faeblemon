extends Node3D

@export var hidePos:Vector3 = Vector3(0,-3,0)
@export var showPos:Vector3 = Vector3(0,4,0)
@export var popSpeed:float = 0.3
@export var popMesh:MeshInstance3D
@export var popLabel:Label3D


@export var buffStages:Array[float]
@export var buffStats:Dictionary[Enums.BuffableAttrs,float]

#func _ready(): #Move up to 3D Subsequencer
	#EventBus.connect("HealthChanged", PopUp)
	#EventBus.connect("BuildupChanged", PopUp)
	#EventBus.connect("GuardChanged", GuardPopup)
	#EventBus.connect("StageChanged", BuffDebuff)

func PopText(amount:int):
	show()
	if popLabel != null:
		popLabel.text = str(amount)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", showPos, popSpeed)
	tween.tween_property(self, "position", showPos, popSpeed*3)
	tween.tween_property(self, "position", hidePos, popSpeed)
	await tween.finished
	hide()


func PopStay(show:bool):
	if show:
		show()
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position", showPos, popSpeed)
		#await get_tree().create_timer(popSpeed*3).timeout
		#hide()
	else:
		#show()
		position = showPos
		await get_tree().create_timer(popSpeed).timeout
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position", hidePos, popSpeed)
		await tween.finished
		hide()


func PopStage(stat:Enums.BuffableAttrs, stage:int):
	var UVTarget:Vector3 = Vector3(buffStats[stat],buffStages[stage],0)
	#await get_tree().create_timer(1.0).timeout #TEMP
	var texture:StandardMaterial3D
	texture = popMesh.get_surface_override_material(0)
	texture.uv1_offset = UVTarget
	popMesh.set_surface_override_material(0, texture)
	show()
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", showPos, popSpeed)
	tween.tween_property(self, "position", showPos, popSpeed*3)
	tween.tween_property(self, "position", hidePos, popSpeed)
	await tween.finished
	hide()
