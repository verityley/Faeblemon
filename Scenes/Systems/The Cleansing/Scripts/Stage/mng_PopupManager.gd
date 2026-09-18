extends Node3D

@export var popups:Dictionary[Elements,Node3D]
var secondaryPop:float = 0.0

enum Elements {
	health=0,
	decay,
	slow,
	silence,
	fixate,
	armorbreak,
	magiGuard,
	physGuard,
	buffDebuff
}


func HealthPop(amount:int, weak:bool,resist:bool,graze:bool,crit:bool):
	secondaryPop = -1.5
	var tags:Array = popups[Elements.health].get_child(0).get_children()
	for tag in tags:
		tag.hide()
	if weak: tags[0].show()
	if resist: tags[1].show()
	if graze: tags[2].show()
	if crit: tags[3].show()
	await popups[Elements.health].PopText(amount)
	secondaryPop = 0.0


func StatusPop(amount:int, type:Enums.Status, weak:bool,resist:bool,graze:bool,crit:bool):
	var tags:Array
	var pop:Node3D
	match type:
		Enums.Status.Decay:
			pop = popups[Elements.decay]
			tags = popups[Elements.decay].get_child(0).get_children()
		Enums.Status.Slow:
			pop = popups[Elements.slow]
			tags = popups[Elements.slow].get_child(0).get_children()
		Enums.Status.Silence:
			pop = popups[Elements.silence]
			tags = popups[Elements.silence].get_child(0).get_children()
		Enums.Status.Fixate:
			pop = popups[Elements.fixate]
			tags = popups[Elements.fixate].get_child(0).get_children()
		Enums.Status.Break:
			pop = popups[Elements.armorbreak]
			tags = popups[Elements.armorbreak].get_child(0).get_children()
	
	if secondaryPop != 0.0:
		pop.showPos.x = secondaryPop
		pop.hidePos.x = secondaryPop
	else:
		pop.showPos.x = 0.0
		pop.hidePos.x = 0.0
	for tag in tags:
		tag.hide()
	if weak: tags[0].show()
	if resist: tags[1].show()
	if graze: tags[2].show()
	if crit: tags[3].show()
	pop.PopText(amount)


func GuardPop(magi:bool, show:bool):
	if magi:
		if show: popups[Elements.magiGuard].PopStay(true)
		else: popups[Elements.magiGuard].PopStay(false)
	else:
		if show: popups[Elements.physGuard].PopStay(true)
		else: popups[Elements.physGuard].PopStay(false)


func BuffPop(stat:Enums.BuffableAttrs, amount:int):
	var stage:int
	match amount:
		-2: stage = 3
		-1: stage = 2
		0: pass #Special reset behavior
		1: stage = 0
		2: stage = 1
	popups[Elements.buffDebuff].PopStage(stat,stage)
