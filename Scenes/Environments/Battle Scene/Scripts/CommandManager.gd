extends Node3D
class_name CommandManager

@export var battleSystem:BattleSystem

#External Variables
var selectedCommand:int

#Setup Variables
@export var commandAnchor:Node3D
@export var moveAnchor:Node3D
@export var commandObjects:Array[Node3D]
@export var attackObjects:Array[Node3D]
@export var commandPositions:Array[Vector3]
@export var attackPositions:Array[Vector3]
@export var rotateTime:float = 0.5
@export var retractHeight:float = 2
@export var lowerHeight:float = 0

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
	await RaiseMenu(true)
	await get_tree().create_timer(6.0).timeout
	MoveMenu(battleSystem.fieldManager.playerObject.position)
	await RaiseMenu(false, battleSystem.playerFaeble.commandOffset)
	await RotateMenu(5)
	await get_tree().create_timer(1.0).timeout
	await RaiseMenu(true)
	await get_tree().create_timer(0.2).timeout
	MoveMenu(battleSystem.fieldManager.enemyObject.position)
	await RaiseMenu(false, battleSystem.enemyFaeble.commandOffset)
	await RotateMenu(-2)

#Process Functions


#Data-Handling Functions


#Tangible Action Functions
func MoveMenu(target:Vector3):
	position = Vector3(position.x,position.y,target.z)

func RaiseMenu(retract:bool, offset:float = 0):
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var target:Vector3
	var target2:Vector3
	if retract:
		target = Vector3(0,retractHeight + offset,0)
		target2 = moveAnchor.position - Vector3(0,0.5,0)
	else:
		target = Vector3(0,lowerHeight + offset,0)
		target2 = moveAnchor.position + Vector3(0,0.5,0)
		show()
	tween.tween_property(commandAnchor, "position", target, rotateTime)
	tween2.tween_property(moveAnchor, "position", target2, rotateTime)
	await tween.finished and tween2.finished
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
