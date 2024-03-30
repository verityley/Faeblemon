extends Node
#Responsible for verifying and enacting movement of battler objects
#Also changes boardstate when actively selecting a movement option
@export var battleManager:BattleManager

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func MoveTo(battler:Battler, location:Vector2i):
	pass

func MoveBy(battler:Battler, amount:Vector2i):
	pass

func CheckMoves(battler:Battler):
	var range = battler.movepoints
	var location = battler.positionIndex
	var inRange:Array[Vector2i]
	
	for x in range(-range, range+1): #Add positions to left and right of battler
		if x == 0:
			continue
		var posIndex:Vector2i = location + Vector2i(x, 0)
		if posIndex.x > 8 or posIndex.x < 0:
			continue
		inRange.append(posIndex)
		print(posIndex, "First Pass")
	
	#Define location on opposite row
	var otherRow:Vector2i
	if location.y == 0:
		otherRow = Vector2i(location.x, 1)
	elif location.y == 1:
		otherRow = Vector2i(location.x, 0)
	print("Other Row Location: ", otherRow)
	#then check left and right in range-1
	for x in range(-range+1, range): #Add positions to left and right of battler
		var posIndex:Vector2i = otherRow + Vector2i(x, 0)
		if posIndex.x > 8 or posIndex.x < 0:
			continue
		inRange.append(posIndex)
		print(posIndex, "Second Pass")
	#Need a part in here that checks for moveblockers, then checks which side moveblocker is on
	#Finally, remove (or prevent appending) any position index > or < than moveblocker posIndex
	for pos in inRange:
		if battleManager.gridDatabase[pos]["Occupied"] == true:
			battleManager.ChangeTileOverlay(pos, "Block")
		else:
			battleManager.ChangeTileOverlay(pos, "Open")

func TakeCost(battler:Battler, amount):
	pass
