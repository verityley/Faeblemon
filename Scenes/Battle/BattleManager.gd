extends Node3D
class_name BattleManager
#BattleManager is responsible for holding universal information, and setting the stage
#Also contains the *actions* for any board or battler changes, but no logic
@export_category("Initialization")
@export var gridDatabase:Dictionary
@export var stageMesh:Node3D
@export var commandMenu:Node3D
@export var stageSize:Vector2i = Vector2i(9,2)
@export var battlerObjects:Array[Battler] #Stores the battler objects for each faebleon the field

@export_category("Camera Parameters")
@export var playerCam:Node
@export var fullstageCam:Camera3D
@export var overviewCam:Camera3D
@export var targetCam:Camera3D

@export_category("Grid Parameters")
@export var clearMat:StandardMaterial3D
@export var blockMat:StandardMaterial3D
@export var openMat:StandardMaterial3D
@export var rangeMat:StandardMaterial3D
@export var targetMat:StandardMaterial3D
@export var selectMat:StandardMaterial3D
@export var gridOffset:Vector3 #This is the position offset at grid position 0,0

@export_category("Board-State Variables")
var boardState:String
#Waiting, Attacking, Moving, Progressing, etc
var selectedGrid:Node3D
var selectedState:String
var selectedPos:Vector2i
var selectedCamera:Node
@export var currentBattler:Battler
var roundOrder:Array[Battler]
#var boardState:String

func _ready():
	PopulateGrid()
	InitBoardState(FaebleStorage.playerParty, FaebleStorage.enemyParty)
	pass

func _input(event):
	if selectedGrid != null: #TEMP FUNCTIONALITY NEEDS STATE CHECK
		if event.is_action_pressed("Confirm") or event.is_action_pressed("LeftMouse"):
			if boardState == "Moving":
				var spentPoints:int #TEMPORARY
				spentPoints = abs(currentBattler.positionIndex.x - selectedPos.x)
				spentPoints += abs(currentBattler.positionIndex.y - selectedPos.y)
				currentBattler.movepoints -= spentPoints
				MoveTo(currentBattler, selectedPos)
				commandMenu.moveTaken = true
			if boardState == "Attacking":
				commandMenu.attackTaken = true
				#TEMPTEMPTEMP
				AttackAnim(currentBattler, selectedPos, true)
			
			for grid in gridDatabase:
				ChangeTileOverlay(grid, "Clear")
			selectedGrid = null
			selectedState = ""
			selectedPos = Vector2i(-1,-1)
			commandMenu.MenuFlow("Start")
			ChangeBoardState("Waiting")
			print(selectedPos)

#------------------------------Board State Functions--------------------------------------

#region Board State Functions
func ChangeBoardState(state:String):
	if (
	state != "Moving" and 
	state != "Attacking" and
	state != "Waiting"
	):
		print(state)
		print("Error! Board state not recognized!")
		return
	#Post error check, assign value
	boardState = state

func InitBoardState(playerTeam:Array[Faeble], enemyTeam:Array[Faeble]):
	#Opening animations
	#Import battlers for each team, assign teams, assign starting locations
	var currentFaeble
	#Player's First Faeble
	currentFaeble = playerTeam.pop_front() 
	if currentFaeble != null and !currentFaeble.fainted:
		AddBattler(0, currentFaeble, true, 3, 1)
	else:
		print("Error! Player has no Faebles to fight with!")
		RemoveBattler(0)
	#Player's Second Faeble
	currentFaeble = playerTeam.pop_front() 
	if currentFaeble != null and !currentFaeble.fainted:
		AddBattler(1, currentFaeble, true, 2, 0)
	else:
		RemoveBattler(1)
	
	#Enemy's First Faeble
	currentFaeble = enemyTeam.pop_front() 
	if currentFaeble != null and !currentFaeble.fainted:
		AddBattler(2, currentFaeble, false, 5, 1)
	else:
		print("Error! Enemy has no Faebles to fight with!")
		RemoveBattler(2)
	#Enemy's Second Faeble
	currentFaeble = enemyTeam.pop_front() 
	if currentFaeble != null and !currentFaeble.fainted:
		AddBattler(3, currentFaeble, false, 6, 0)
	else:
		RemoveBattler(3)
	#Initialize connections to stat cards
	#Initialize turn order and set first turn actor
	#TEMP
	commandMenu.selectedBattler = battlerObjects[0]
	battlerObjects[0].add_child(commandMenu)
	commandMenu.MenuFlow("Start")
	#END TEMP
#endregion

#------------------------------Grid Functions--------------------------------------

#region Grid Functions
func PopulateGrid():
	var vectorIndex:Vector2i = Vector2i(0,0)
	var squareIndex:int = -1
	var stageSquares:Array[Node] = stageMesh.get_children()
	for yIndex in range(stageSize.y):
		vectorIndex.y = yIndex
		for xIndex in range(stageSize.x):
			vectorIndex.x = xIndex
			squareIndex += 1
			var attributes:Dictionary = {}
			attributes["Square"] = stageSquares[squareIndex] #Holds the gridsquare mesh
			attributes["State"] = "Clear"
			attributes["Active"] = bool(false)
			attributes["Occupied"] = bool(false) #if tile is blocked and filled
			attributes["Obstacle"] = null #Any stage hazard present, not all Occupy
			attributes["Occupancy"] = null #Battler present in that position
			gridDatabase[vectorIndex] = attributes
			ChangeTileOverlay(vectorIndex, "Clear")
			#prints(vectorIndex, gridDatabase[vectorIndex]["Square"].name)

func ChangeTileData(location:Vector2i, attribute:String, dataToChange):
	if !gridDatabase[location].has(attribute):
		print("Error! Grid does not have attribute of listed type!")
		return
	if attribute == "Square" and not dataToChange is Node:
		print("Error! Grid Square must be of type: Node")
		return
	if attribute == "State" and not dataToChange is String:
		print("Error! State change must be of type: String")
		return
	if attribute == "Active" and not dataToChange is bool:
		print("Error! Active state must be of type: Bool")
		return
	if attribute == "Occupied" and not dataToChange is bool:
		print("Error! Occupied status must be of type: Bool")
		return
	if attribute == "Obstacle" and not dataToChange is Node:
		if dataToChange != null:
			print("Error! Obstacle entity must be of type: Obstacle")
			return
	if attribute == "Occupancy" and not dataToChange is Battler:
		if dataToChange != null:
			print("Error! Occupancy entity must be of type: Battler")
			return
	#Post error check, assign value
	gridDatabase[location][attribute] = dataToChange

func ChangeTileOverlay(location:Vector2i, state:String):
	var gridSquare = gridDatabase[location]["Square"]
	if state == "Clear":
		gridSquare.set_surface_override_material(0, clearMat)
		ChangeTileData(location, "Active", false)
		ChangeTileData(location, "State", "Clear")
		#print("Grid Cleared")
	elif state == "Block":
		gridSquare.set_surface_override_material(0, blockMat)
		ChangeTileData(location, "Active", false)
		ChangeTileData(location, "State", "Block")
	elif state == "Open":
		gridSquare.set_surface_override_material(0, openMat)
		ChangeTileData(location, "Active", true)
		ChangeTileData(location, "State", "Open")
	elif state == "Range":
		gridSquare.set_surface_override_material(0, rangeMat)
		ChangeTileData(location, "Active", true)
		ChangeTileData(location, "State", "Range")
	elif state == "Target":
		gridSquare.set_surface_override_material(0, targetMat)
		ChangeTileData(location, "Active", true)
		ChangeTileData(location, "State", "Target")

func SelectSquare(location:Vector2i, exit=false):
	if !gridDatabase[location]["Active"]:
		return
	if exit:
		ChangeTileOverlay(location, selectedState)
		selectedGrid = null
		return
	selectedGrid = gridDatabase[location]["Square"]
	selectedState = gridDatabase[location]["State"]
	selectedPos = location
	selectedGrid.set_surface_override_material(0, selectMat)
	#Send signal that something was selected

func SelectArea(location:Vector2i, atkRange:int, exit=false, allRows:bool=false):
	var gridArea:Array[Vector2i]
	if !gridDatabase[location]["Active"]:
		return
	for x in range(-atkRange, atkRange+1): #Add positions to left and right of battler
		if x == 0:
			continue
		var posIndex:Vector2i = location + Vector2i(x, 0)
		if posIndex.x > 8 or posIndex.x < 0:
			continue
		gridArea.append(posIndex)
		#print(posIndex, "First Pass")
	#Define location on opposite row
	if allRows == true:
		var otherRow:Vector2i
		if location.y == 0:
			otherRow = Vector2i(location.x, 1)
		elif location.y == 1:
			otherRow = Vector2i(location.x, 0)
		print("Other Row Location: ", otherRow)
		#then check left and right in range-1
		for x in range(-atkRange+1, atkRange): #Add positions to left and right of battler
			var posIndex:Vector2i = otherRow + Vector2i(x, 0)
			if posIndex.x > 8 or posIndex.x < 0:
				continue
			gridArea.append(posIndex)
	if exit:
		for grid in gridArea:
			ChangeTileOverlay(grid, gridDatabase[grid]["State"])
		#selectedGrid = null
		return
	else:
		for grid in gridArea:
			gridDatabase[grid]["Square"].set_surface_override_material(0, selectMat)
	#Send signal that something was selected
#endregion

#------------------------------Battler Functions--------------------------------------

#region Battler Functions
func SwapBattler():
	pass

func AddBattler(index:int, faebleInstance:Faeble, player:bool, xPos:int, yPos:int):
	battlerObjects[index].faebleEntry = faebleInstance
	battlerObjects[index].playerControl = player
	battlerObjects[index].currentHP = faebleInstance.maxHP
	battlerObjects[index].currentEnergy = faebleInstance.maxEnergy
	battlerObjects[index].currentSpeed = faebleInstance.grace
	battlerObjects[index].hide()
	battlerObjects[index].position = Vector3(xPos,0,yPos) + gridOffset
	battlerObjects[index].positionIndex = Vector2i(xPos,yPos)
	ChangeTileData(Vector2i(xPos,yPos), "Occupancy", battlerObjects[index])
	ChangeTileData(Vector2i(xPos,yPos), "Occupied", true)
	var texture = battlerObjects[index].get_child(0).get_surface_override_material(0)
	texture.albedo_texture = faebleInstance.sprite
	battlerObjects[index].show()

func RemoveBattler(index:int):
	battlerObjects[index].hide()
	#battlers.remove_at(polePosition)

func AttachMenu():
	pass #Change parent of command menu, and reset menu states

func ChangeCard():
	pass

func ShowHideCard():
	pass
#endregion

#------------------------------Turn Functions--------------------------------------
#START HERE NEXT ERIKA, Turn-end button too, or end when move and attack fulfilled

#region Turn Functions
func InitOrder():
	print("Starting new battle.")
	PopulateOrder()

func PopulateOrder():
	pass

func ProgressTurn():
	pass

func NewRound():
	pass

func SpeedSorter(a:Battler,b:Battler) -> bool:
	if a.currentSpeed > b.currentSpeed:
		return true
	return false

func ResetSpeed(battlers:Array[Battler]):
	for battler in battlers:
		var speedMod:int = 0
		var pointsMod:int = 1
		#if speed reduce status threshold met, -x on speedmod
		#if speed stage up or down, +x to speedmod
		#if solo, +1 pointsmod
		battler.currentSpeed = battler.faebleEntry.grace + speedMod
		battler.movepoints = battler.currentSpeed/5 + pointsMod
#endregion

#------------------------------Movement Functions--------------------------------------

#region Movement Functions
func MoveTo(battler:Battler, location:Vector2i):
	print("Moving!")
	var tween = get_tree().create_tween()
	var mesh = battler.get_child(0)
	var facing:float = mesh.rotation.y
	print("Facing ", facing)
	if battler.positionIndex.x < location.x:
		facing = deg_to_rad(180)
	elif battler.positionIndex.x > location.x:
		facing = 0
	print("Facing, after change: ", facing)
	#Target position offset is x-4.5, y=0.5, z-0.5
	ChangeTileData(battler.positionIndex, "Occupancy", null)
	ChangeTileData(battler.positionIndex, "Occupied", false)
	commandMenu.hide()
	var distance = abs(location.x - battler.positionIndex.x)*0.3
	if facing != mesh.rotation.y:
		tween.tween_property(mesh, "rotation", Vector3(0,facing,0), distance/2)
	tween.tween_property(battler, "position", (Vector3(location.x,0,battler.positionIndex.y) + gridOffset), distance)
	tween.tween_property(battler, "position", (Vector3(location.x,0,location.y) + gridOffset), 0.2)
	await tween.finished
	commandMenu.position = battler.position + commandMenu.menuOffset
	commandMenu.show()
	battler.positionIndex = location
	print("Facing, after tween: ", mesh.rotation.y)
	ChangeTileData(location, "Occupancy", battler)
	ChangeTileData(location, "Occupied", true)
	

func MoveBy(battler:Battler, amount:Vector2i):
	var targetPos:Vector2i = battler.positionIndex + amount
	MoveTo(battler, targetPos)

func CheckMoves(battler:Battler):
	var atkRange = battler.movepoints
	var location = battler.positionIndex
	var inRange:Array[Vector2i]
	for x in range(-atkRange, atkRange+1): #Add positions to left and right of battler
		if x == 0:
			continue
		var posIndex:Vector2i = location + Vector2i(x, 0)
		if posIndex.x > 8 or posIndex.x < 0:
			continue
		inRange.append(posIndex)
		#print(posIndex, "First Pass")
	#Define location on opposite row
	var otherRow:Vector2i
	if location.y == 0:
		otherRow = Vector2i(location.x, 1)
	elif location.y == 1:
		otherRow = Vector2i(location.x, 0)
	print("Other Row Location: ", otherRow)
	#then check left and right in range-1
	for x in range(-atkRange+1, atkRange): #Add positions to left and right of battler
		var posIndex:Vector2i = otherRow + Vector2i(x, 0)
		if posIndex.x > 8 or posIndex.x < 0:
			continue
		inRange.append(posIndex)
		#print(posIndex, "Second Pass")
	#Need a part in here that checks for moveblockers, then checks which side moveblocker is on
	#Finally, remove (or prevent appending) any position index > or < than moveblocker posIndex
	for pos in inRange:
		if gridDatabase[pos]["Occupied"] == true:
			ChangeTileOverlay(pos, "Block")
		else:
			ChangeTileOverlay(pos, "Open")
#endregion

#------------------------------Attack Functions--------------------------------------

#region Attack Functions
func CheckAttackRange(battler:Battler, attack:Skill):
	var rangeMin = attack.rangeMin
	var rangeMax = attack.rangeMax
	var location = battler.positionIndex
	var inRange:Array[Vector2i]
	for x in range(-rangeMax, rangeMax+1): #Add positions to left and right of battler
		if x == 0:
			continue
		if x > -rangeMin and x < rangeMin:
			continue
		var posIndex:Vector2i = location + Vector2i(x, 0)
		if posIndex.x > 8 or posIndex.x < 0:
			continue
		inRange.append(posIndex)
		#print(posIndex, "First Pass")
	#Define location on opposite row
	var otherRow:Vector2i
	if location.y == 0:
		otherRow = Vector2i(location.x, 1)
	elif location.y == 1:
		otherRow = Vector2i(location.x, 0)
	print("Other Row Location: ", otherRow)
	#then check left and right in range-1
	if attack.canArc == true:
		for x in range(-rangeMax+1, rangeMax): #Add positions to left and right of battler
			if x == 0:
				continue
			var posIndex:Vector2i = otherRow + Vector2i(x, 0)
			if posIndex.x > 8 or posIndex.x < 0:
				continue
			inRange.append(posIndex)
			#print(posIndex, "Second Pass")
	if rangeMin <= 1:
		inRange.append(otherRow)
	#Need a part in here that checks for moveblockers, then checks which side moveblocker is on
	#Finally, remove (or prevent appending) any position index > or < than moveblocker posIndex
	for pos in inRange:
		if gridDatabase[pos]["Occupied"] == true:
			if attack.targetAll:
				ChangeTileOverlay(pos, "Target")
			elif gridDatabase[pos]["Occupancy"].playerControl == false and !attack.targetAlly:
				ChangeTileOverlay(pos, "Target")
			elif gridDatabase[pos]["Occupancy"].playerControl == true and !attack.targetAlly:
				ChangeTileOverlay(pos, "Block")
			elif gridDatabase[pos]["Occupancy"].playerControl == false and attack.targetAlly:
				ChangeTileOverlay(pos, "Block")
			elif gridDatabase[pos]["Occupancy"].playerControl == true and attack.targetAlly:
				ChangeTileOverlay(pos, "Target")
		else:
			ChangeTileOverlay(pos, "Range")

func CheckOffenses():
	pass

func CheckDefenses():
	pass

func CheckMatchups():
	pass

func DamageCalc():
	pass

func AttackAnim(battler:Battler, target:Vector2i, melee:bool):
	var tween = get_tree().create_tween()
	var mesh = battler.get_child(0)
	var facing:float = mesh.rotation.y
	var pos1:Vector3
	if melee:
		pos1 = Vector3(target.x, 0, target.y) + gridOffset
	else:
		pos1 = Vector3(0.2, 0.2, 0) + battler.position# + gridOffset
	var pos2:Vector3 = battler.position
	if battler.positionIndex.x < target.x:
		facing = deg_to_rad(180)
	elif battler.positionIndex.x > target.x:
		facing = 0
	#Target position offset is x-4.5, y=0.5, z-0.5
	if facing != mesh.rotation.y:
		tween.tween_property(mesh, "rotation", Vector3(0,facing,0), 0.3)
	tween.tween_property(battler, "position", pos1, 0.2)
	tween.tween_property(battler, "position", pos2, 0.2)
	await tween.finished
#endregion

#------------------------------Camera Functions--------------------------------------

func ChangeCam():
	pass
