extends Node3D

@export var battleSystem:BattleSystem

#External Variables
var intendedMovement:int = 0
#Left is -1, Right is +1, if player * -1
#Left to close distance, right to increase distance

#Setup Variables
@export var moveTime:float = 0.5
@export var arrowPositions:Array[Vector3]
@export var arrowObjects:Array[Node3D]

#Internal Variables
var pickedDirection:int
var moving:bool = false
var arrowIndex:int
var enemySelected:bool = false

#Setup Functions
func _ready():
	#await RotateMenu(5)
	#await get_tree().create_timer(1.0).timeout
	#await RaiseMenu(true)
	#await get_tree().create_timer(0.2).timeout
	#MoveMenu(battleSystem.fieldManager.enemyObject.position)
	#await RaiseMenu(false, battleSystem.enemyFaeble.commandOffset)
	#await RotateMenu(-2)
	pass

#Process Functions
func _input(event):
	if pickedDirection != 0 and !moving:
		if event.is_action_pressed("LeftMouse"):
			SelectCommand(pickedDirection)


func TargetMovement(selected:bool, direction:int=0):
	if selected == false:
		pickedDirection = 0
		print("No Command")
		return
	pickedDirection = direction
	print("Direction: ", direction)
	#print("Command: ", command)

func SelectCommand(direction:int):
	var flip:int = 1
	moving = true
	if enemySelected:
		print("Enemy, flipping direction: ", (direction*flip))
		flip = -1
	#print("Command Selected! ", command)
	print("Intended Movement: ", intendedMovement + (direction*flip))
	if intendedMovement + direction < 4 and intendedMovement + direction > -4:
		battleSystem.fieldManager.RotateMarker(direction*flip)
		await ArrowIndexing(direction)
		#await RotateToFront(command)
		intendedMovement += direction
	moving = false

#Data-Handling Functions
func ArrowIndexing(direction:int):
	var current:int = intendedMovement + 3
	var arrow:int = current + direction
	
	if arrow > 6 or arrow < 0:
		print("Hit Movement Limit!")
		return
	if arrow > 3:
		if arrow > current:
			prints(current, arrow)
			await MoveArrow(arrow, arrow, false)
		elif arrow < current:
			prints(current, arrow)
			await MoveArrow(current, arrow, true)
	elif arrow < 3:
		if arrow < current:
			prints(current, arrow)
			await MoveArrow(arrow, arrow, false)
		elif arrow > current:
			prints(current, arrow)
			await MoveArrow(current, arrow, true)
	elif arrow == 3:
		await MoveArrow(current, arrow, true)

#Tangible Action Functions
func ResetArrows():
	print("Range: ",abs(intendedMovement))
	for i in range(abs(intendedMovement)):
		if intendedMovement > 0:
			print("Resetting Arrow")
			ArrowIndexing(-1)
			await battleSystem.fieldManager.RotateMarker(-1)
		else:
			print("Resetting Arrow")
			ArrowIndexing(1)
			await battleSystem.fieldManager.RotateMarker(1)

func MoveArrow(fromIndex:int, toIndex:int, hide:bool):
	var tween = get_tree().create_tween()
	arrowObjects[fromIndex].show()
	tween.tween_property(arrowObjects[fromIndex], "position", arrowPositions[toIndex], moveTime)
	await tween.finished
	if hide:
		arrowObjects[fromIndex].hide()

#placeholder order of operations:
