extends Node3D
class_name ManaManager

@export var manaBubbles:Array[Node3D]
@export var manaPool:Array[int] = [0,0,0]
@export var anchorRotations:Array[float]
@export var scrollTime:float

enum Mana{
	Primordial=1,
	Enchantment,
	Arcane,
	Wild
}

func _ready():
	InitMana()
	await get_tree().create_timer(3.0).timeout
	await AddMana(1)
	await AddMana(2)
	await AddMana(3)



func InitMana():
	for bubble in manaBubbles:
		bubble.hide()
		bubble.get_child(0).frame = 0
		bubble.rotation.z = deg_to_rad(anchorRotations[0])

func AddMana(type:int):
	var nextEmpty:int = -1
	for m in range(manaPool.size()):
		if manaPool[m] == 0:
			nextEmpty = m
			break
	if nextEmpty == -1:
		await RemoveMana(-1,1)
		nextEmpty = 2
	manaPool[nextEmpty] = type
	var target = manaBubbles[nextEmpty]
	var roTarget:Vector3 = Vector3(0,0,deg_to_rad(anchorRotations[nextEmpty+1]))
	target.rotation.z = deg_to_rad(anchorRotations[4])
	target.get_child(0).frame = type-1
	target.show()
	var rotaTween = get_tree().create_tween()
	rotaTween.tween_property(target, "rotation", roTarget, scrollTime * (3-nextEmpty))
	await rotaTween.finished

func RemoveMana(type:int, amount:int):
	print("Running Removal")
	var toRemove:Array[int]
	if type == -1:
		toRemove.append(0)
	else:
		for i in range(amount):
			var found = manaPool.find(type)
			if found == -1:
				continue
			toRemove.append(found)
			manaPool[found] = 0
		if toRemove.size() < amount:
			var found = manaPool.find(4)
			toRemove.append(found)
			manaPool[found] = 0
	
	for m in toRemove:
		var target = manaBubbles[m].get_child(0)
		var roTarget:Vector3 = Vector3(0.01,0.01,0.01)
		var rotaTween = get_tree().create_tween()
		rotaTween.tween_property(target, "scale", roTarget, scrollTime)
	await get_tree().create_timer(scrollTime+0.01).timeout
	for r in toRemove:
		var target = manaBubbles[r]
		target.hide()
		target.get_child(0).frame = 0
		target.rotation.z = deg_to_rad(anchorRotations[0])
		target.get_child(0).scale = Vector3(0.12,0.12,0.12) #TEMP, replace with export variable later
	var removalCountdown:int = amount
	while removalCountdown > 0:
		await ReorderMana(toRemove[removalCountdown-1])
		removalCountdown -= 1


func ReorderMana(removedIndex:int):
	match removedIndex:
		0:
			print("First index position removed, shifting 2 and 3 -> 1 and 2")
			var target = manaBubbles[1]
			prints("Moving: ",target)
			var roTarget:Vector3 = Vector3(0,0,deg_to_rad(anchorRotations[1]))
			var rotaTween = get_tree().create_tween()
			rotaTween.tween_property(target, "rotation", roTarget, scrollTime)
			var target2 = manaBubbles[2]
			var roTarget2:Vector3 = Vector3(0,0,deg_to_rad(anchorRotations[2]))
			var rotaTween2 = get_tree().create_tween()
			rotaTween2.tween_property(target2, "rotation", roTarget2, scrollTime)
			await get_tree().create_timer(scrollTime+0.01).timeout
			manaBubbles.append(manaBubbles.pop_at(0))
			manaPool.append(manaPool.pop_at(0))
		1:
			print("Second index position removed, shifting 3 -> 2")
			var target = manaBubbles[2]
			var roTarget:Vector3 = Vector3(0,0,deg_to_rad(anchorRotations[2]))
			var rotaTween = get_tree().create_tween()
			rotaTween.tween_property(target, "rotation", roTarget, scrollTime)
			await get_tree().create_timer(scrollTime+0.01).timeout
			manaBubbles.append(manaBubbles.pop_at(0))
			manaPool.append(manaPool.pop_at(0))
		2:
			return

func OverflowMana():
	pass
