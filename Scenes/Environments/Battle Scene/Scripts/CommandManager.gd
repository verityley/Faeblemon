extends Node3D
class_name CommandManager

@export var battleSystem:BattleSystem

#External Variables
var selectedCommand:int

#Setup Variables
@export var commandObjects:Array[Node3D]
@export var attackObjects:Array[Node3D]
@export var commandPositions:Array[Vector3]
@export var attackPositions:Array[Vector3]
@export var rotateTime:float = 0.5

enum Actions{
	Attack1=1,
	Attack2,
	Attack3,
	Guard,
	Recharge,
	Dash,
	Switch
}

#Internal Variables


#Setup Functions
func _ready():
	pass

#Process Functions


#Data-Handling Functions


#Tangible Action Functions
func MoveMenu(target:Vector3):
	position = Vector3(position.x,position.y,target.z)

func RaiseMenu(retract:bool):
	var tween = get_tree().create_tween()
	var target:Vector3
	if retract:
		target = position + Vector3(0,3,0)
	else:
		target = position - Vector3(0,3,0)
		show()
	tween.tween_property(self, "position", target, rotateTime)
	await tween.finished
	if retract:
		hide()

func RotateMenu(amount:int):
	var tweenArray:Array
	tweenArray.resize(5)
	var newTargets:Array[Vector3] = commandPositions.duplicate()
	for i in range(abs(amount)):
		var toCycle
		for tween in range(5):
			tweenArray[tween] = get_tree().create_tween()
		if amount > 0:
			toCycle = newTargets.pop_front()
			newTargets.append(toCycle)
		if amount < 0:
			toCycle = newTargets.pop_back()
			newTargets.push_front(toCycle)
		#print(newTargets)
		tweenArray[0].tween_property(commandObjects[0], "position", newTargets[0], rotateTime)
		tweenArray[1].tween_property(commandObjects[1], "position", newTargets[1], rotateTime)
		tweenArray[2].tween_property(commandObjects[2], "position", newTargets[2], rotateTime)
		tweenArray[3].tween_property(commandObjects[3], "position", newTargets[3], rotateTime)
		tweenArray[4].tween_property(commandObjects[4], "position", newTargets[4], rotateTime)
		await tweenArray[0].finished
		commandPositions = newTargets

func RevealAttacks(): #attacks:Array[Skill]
	var tweenArray:Array
	var rotationTween = get_tree().create_tween()
	var rotationTween2 = get_tree().create_tween()
	rotationTween.tween_property(commandObjects[0], "rotation", Vector3(0,deg_to_rad(90),0), rotateTime)
	rotationTween2.tween_property(attackObjects[0], "rotation", Vector3(0,0,0), rotateTime)
	await rotationTween.finished
	tweenArray.resize(3)
	for tween in range(3):
		tweenArray[tween] = get_tree().create_tween()
	attackObjects[1].show()
	attackObjects[2].show()
	tweenArray[0].tween_property(attackObjects[0], "position", attackPositions[0], rotateTime)
	tweenArray[1].tween_property(attackObjects[1], "position", attackPositions[1], rotateTime)
	tweenArray[2].tween_property(attackObjects[2], "position", attackPositions[2], rotateTime)
	await tweenArray[0].finished

func RotateAttacks(amount:int):
	var tweenArray:Array
	tweenArray.resize(3)
	var newTargets:Array[Vector3] = attackPositions.duplicate()
	for i in range(abs(amount)):
		var toCycle
		for tween in range(3):
			tweenArray[tween] = get_tree().create_tween()
		if amount > 0:
			toCycle = newTargets.pop_front()
			newTargets.append(toCycle)
		if amount < 0:
			toCycle = newTargets.pop_back()
			newTargets.push_front(toCycle)
		#print(newTargets)
		tweenArray[0].tween_property(attackObjects[0], "position", newTargets[0], rotateTime)
		tweenArray[1].tween_property(attackObjects[1], "position", newTargets[1], rotateTime)
		tweenArray[2].tween_property(attackObjects[2], "position", newTargets[2], rotateTime)
		await tweenArray[0].finished
	attackPositions = newTargets

#placeholder order of operations:
