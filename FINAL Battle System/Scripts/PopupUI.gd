extends Node3D

@export var attached:BattlerData
@export var popups:Dictionary[Enums.Status,Node3D]
@export var buffStages:Array[float]
@export var buffStats:Dictionary[Enums.BuffableAttrs,float]
@export var physGuard:Node3D
@export var magiGuard:Node3D
@export var buffPop:Node3D

func _ready():
	EventBus.connect("HealthChanged", PopUp)
	EventBus.connect("BuildupChanged", PopUp)
	EventBus.connect("GuardChanged", GuardPopup)
	EventBus.connect("StageChanged", BuffDebuff)

func PopUp(target:BattlerData, amount:int, type:int=0):
	var pop:Node3D
	if target != attached:
		#print("Signal not for me! (Status Popup)")
		return #This signal is not for me
	#if amount > 0:
		#pass #This means it is a healing popup, change to heal sprite
		#return
	if type == Enums.Status.Catalyze:
		type = target.buildupTarget #TEMP, will eventually want bespoke catalyze popup icon
		#Use catalyze icon if buildup is over half, for clarity
	prints("Popup: ",Enums.Status.keys()[type])
	pop = popups[type]
	pop.get_child(0).text = str(amount)
	await get_tree().create_timer(1.0).timeout #TEMP
	pop.show()
	var tween = get_tree().create_tween()
	tween.tween_property(pop, "position", Vector3(0,4,0), 0.3)
	tween.tween_property(pop, "position", Vector3(0,4,0), 1.0)
	tween.tween_property(pop, "position", Vector3(0,-3,0), 0.3)
	await tween.finished
	pop.hide()

func GuardPopup(target:BattlerData):
	if target != attached:
		print("Signal not for me! (Guard Popup)")
		return #This signal is not for me
	var phyTween = get_tree().create_tween()
	var magTween = get_tree().create_tween()
	if target.pGuard > 0:
		physGuard.show()
		phyTween.tween_property(physGuard, "position", Vector3(0,1.5,1.5), 0.5)
	elif target.pGuard == 0:
		phyTween.tween_property(physGuard, "position", Vector3(0,-5,1.5), 0.3)
	if target.mGuard > 0:
		magiGuard.show()
		magTween.tween_property(magiGuard, "position", Vector3(0,1.5,1.5), 0.5)
	elif target.mGuard == 0:
		magTween.tween_property(magiGuard, "position", Vector3(0,-5,1.5), 0.3)
	await phyTween.finished or magTween.finished
	if target.pGuard == 0:
		physGuard.hide()
	if target.mGuard == 0:
		magiGuard.hide()

func BuffDebuff(target:BattlerData, stat:Enums.BuffableAttrs, amount:int):
	if target != attached:
		print("Signal not for me! (Buff Popup)")
		return #This signal is not for me
	var stage:int
	match amount:
		-2: stage = 3
		-1: stage = 2
		0: pass #Special reset behavior
		1: stage = 0
		2: stage = 1
	var UVTarget:Vector3 = Vector3(buffStats[stat],buffStages[stage],0)
	await get_tree().create_timer(1.0).timeout #TEMP
	var texture:StandardMaterial3D
	texture = buffPop.get_surface_override_material(0)
	texture.uv1_offset = UVTarget
	buffPop.set_surface_override_material(0, texture)
	buffPop.show()
	var tween = get_tree().create_tween()
	tween.tween_property(buffPop, "position", Vector3(0,1.5,1.5), 0.3)
	tween.tween_property(buffPop, "position", Vector3(0,1.5,1.5), 1.0)
	tween.tween_property(buffPop, "position", Vector3(0,-5,1.5), 0.3)
	await tween.finished
	buffPop.hide()
