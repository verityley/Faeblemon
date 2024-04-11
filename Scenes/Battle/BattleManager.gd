extends Node3D
class_name BattleManager
#BattleManager is responsible for holding universal information, and setting the stage
#Also contains the *actions* for any board or battler changes, but no logic
@export_category("Initialization")
@export var gridDatabase:Dictionary
@export var stageMesh:Node3D
@export var commandMenu:Commands
@export var battleUI:Node
var battleBoxes:Array[StatusBox]
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
var selectedArea:Array[Vector2i]
var selectedCamera:Node
#var boardState:String

@export_category("Battle-State Variables")
@export var currentPhase:PlanarPhase
@export var currentBattler:Battler
var currentSkill:Skill
var roundOrder:Array[Battler]
#@export var weaknessFactor:float = 0.5
#@export var resistanceFactor:float = 1
#@export var defenseFactor:float = 0
@export var stageIncrease:int = 2


func _ready():
	FaebleCreation.CreateEncounter(FaebleStorage.enemyParty, 4, null)
	PopulateGrid()
	InitBoardState(FaebleStorage.playerParty, FaebleStorage.enemyParty)
	InitOrder()
	pass

func _input(event):
	if event.is_action_pressed("RightMouse") and boardState != "Waiting":
		if boardState == "Moving":
			SelectSquare(selectedPos, true)
			commandMenu.HideMenu(false, true)
		
		if boardState == "Attacking":
			SelectSquare(selectedPos, true)
			commandMenu.HideMenu(false, true)
		
		for grid in gridDatabase:
			ChangeTileOverlay(grid, "Clear")
		selectedGrid = null
		selectedState = ""
		selectedPos = Vector2i(-1,-1)
		ChangeBoardState("Waiting")
	if selectedGrid != null: #TEMP FUNCTIONALITY NEEDS STATE CHECK
		if event.is_action_pressed("Confirm") or event.is_action_pressed("LeftMouse"):
			if boardState == "Moving":
				#TEMPORARY
				var spentPoints:int 
				spentPoints = abs(currentBattler.positionIndex.x - selectedPos.x)
				spentPoints += abs(currentBattler.positionIndex.y - selectedPos.y)
				currentBattler.ChangeMovepoints(-spentPoints)
				#currentBattler.currentSpeed -= spentPoints*5
				#TEMP TEMP TEMP
				commandMenu.HideMenu(true, true)
				MoveTo(currentBattler, selectedPos)
				commandMenu.moveTaken = true
				commandMenu.familiarChosen = true
				commandMenu.HideMenu(false, false)
			if boardState == "Attacking":
				if currentSkill.canBurst:
					for grid in selectedArea:
						if gridDatabase[grid]["Occupant"] != null:
							currentSkill.Execute(self, currentBattler, gridDatabase[grid]["Occupant"])
				elif gridDatabase[selectedPos]["Occupant"] != null:
					currentSkill.Execute(self, currentBattler, gridDatabase[selectedPos]["Occupant"])
					AttackAnim(currentBattler, selectedPos, true)
				commandMenu.HideMenu(true, true)
				commandMenu.attackTaken = true
				commandMenu.familiarChosen = true
				commandMenu.HideMenu(false, false)
				#TEMPTEMPTEMP
			
			for grid in gridDatabase:
				ChangeTileOverlay(grid, "Clear")
			selectedGrid = null
			selectedState = ""
			selectedPos = Vector2i(-1,-1)
			commandMenu.MenuFlow("Start")
			ChangeBoardState("Waiting")
			#print(selectedPos)

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
	for box in battleUI.get_children():
		battleBoxes.append(box)
	var currentFaeble
	var removeBattler:Array = [null, null, null, null]
	var partyIndex:int = 0
	#Player's First Faeble
	currentFaeble = playerTeam[partyIndex]
	while currentFaeble == null or currentFaeble.fainted:
		partyIndex += 1
		if partyIndex >= FaebleStorage.maxPartySize:
			print("Error! Player has no Faebles to fight with!")
			print("P.S. This should never happen.")
			removeBattler[0] = battlerObjects[0]
			currentFaeble = null
			break
		print("Faeble not available, choosing next in party.")
		currentFaeble = playerTeam[partyIndex]
	if currentFaeble != null:
		AddBattler(0, currentFaeble, true, 3, 1)
		print("Faeble found, assigning, ", currentFaeble.name," to player position 1.")
	
	#Player's Second Faeble
	partyIndex += 1
	if partyIndex < FaebleStorage.maxPartySize:
		currentFaeble = playerTeam[partyIndex]
		while currentFaeble == null or currentFaeble.fainted:
			partyIndex += 1
			if partyIndex >= FaebleStorage.maxPartySize:
				print("Error! Player has no Faebles left to partner up!")
				removeBattler[1] = battlerObjects[1]
				currentFaeble = null
				break
			print("Faeble not available, choosing next in party.")
			currentFaeble = playerTeam[partyIndex]
		if currentFaeble != null:
			AddBattler(1, currentFaeble, true, 2, 0)
			print("Faeble found, assigning, ", currentFaeble.name," to player position 2.")
	else:
		removeBattler[1] = battlerObjects[1]
		print("Error! Player has no Faebles left to partner up!")
	
	#Enemy's First Faeble
	partyIndex = 0
	currentFaeble = enemyTeam[partyIndex]
	while currentFaeble == null or currentFaeble.fainted:
		partyIndex += 1
		if partyIndex >= FaebleStorage.maxPartySize:
			print("Error! Enemy has no Faebles to fight with!")
			print("P.S. This should never EVER happen.")
			removeBattler[2] = battlerObjects[2]
			currentFaeble = null
			break
		print("Faeble not available, choosing next in party.")
		currentFaeble = enemyTeam[partyIndex]
	if currentFaeble != null:
		AddBattler(2, currentFaeble, false, 5, 1)
		print("Faeble found, assigning, ", currentFaeble.name," to enemy position 1.")
	
	#Enemy's Second Faeble
	partyIndex += 1
	if partyIndex < FaebleStorage.maxPartySize:
		currentFaeble = enemyTeam[partyIndex]
		while currentFaeble == null or currentFaeble.fainted:
			partyIndex += 1
			if partyIndex >= FaebleStorage.maxPartySize:
				print("Error! Enemy has no Faebles left to partner up!")
				removeBattler[3] = battlerObjects[3]
				currentFaeble = null
				break
			print("Faeble not available, choosing next in party.")
			currentFaeble = enemyTeam[partyIndex]
		if currentFaeble != null:
			AddBattler(3, currentFaeble, false, 6, 0)
			print("Faeble found, assigning, ", currentFaeble.name," to enemy position 2.")
	else:
		removeBattler[3] = battlerObjects[3]
		print("Error! Enemy has no Faebles left to partner up!")
	
	#Remove as one batch after init, to ensure AddBattler doesnt break.
	#print(battlerObjects)
	var index:int = 0
	for battler in removeBattler:
		if battler != null:
			battler.hide()
			battleBoxes[index].hide()
			#battlerObjects.erase(battler)
		index += 1
	#print(battlerObjects)
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
			attributes["Occupant"] = null #Battler present in that position
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
	if attribute == "Occupant" and not dataToChange is Battler:
		if dataToChange != null:
			print("Error! Occupant entity must be of type: Battler")
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
		if boardState == "Moving":
			currentBattler.statusBox.SetMovepointsDisplay(currentBattler.movepoints)
			currentBattler.statusBox.SetSpeedDisplay(currentBattler.currentSpeed)
		if boardState == "Attacking":
			if currentSkill.canBurst == true:
				print("Exiting AoE")
				SelectArea(location, currentSkill.burstRange, true, currentSkill.canArc)
		return
	selectedGrid = gridDatabase[location]["Square"]
	selectedState = gridDatabase[location]["State"]
	selectedPos = location
	selectedGrid.set_surface_override_material(0, selectMat)
	#TEMP TEMP TEMP
	if boardState == "Moving":
		var estPoints:int 
		estPoints = abs(currentBattler.positionIndex.x - selectedPos.x)
		estPoints += abs(currentBattler.positionIndex.y - selectedPos.y)
		currentBattler.statusBox.SetMovepointsDisplay(currentBattler.movepoints - estPoints)
		var estSpeed:int = clampi(currentBattler.currentSpeed - (estPoints*5),0,30)
		currentBattler.statusBox.SetSpeedDisplay(estSpeed)
	
	if boardState == "Attacking":
		if currentSkill.canBurst == true:
			print("Targeting AoE")
			SelectArea(location, currentSkill.burstRange, false, currentSkill.canArc)
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
		selectedArea.clear()
		return
	else:
		for grid in gridArea:
			gridDatabase[grid]["Square"].set_surface_override_material(0, selectMat)
		selectedArea = gridArea.duplicate()
	#Send signal that something was selected
	
#endregion

#------------------------------Battler Functions--------------------------------------

#region Battler Functions
func SwapBattler():
	pass

func AddBattler(index:int, faebleInstance:Faeble, player:bool, xPos:int, yPos:int):
	battlerObjects[index].faebleEntry = faebleInstance
	battlerObjects[index].playerControl = player
	battlerObjects[index].statusBox = battleBoxes[index]
	battlerObjects[index].currentHP = faebleInstance.maxHP
	battlerObjects[index].currentEnergy = faebleInstance.maxEnergy
	battlerObjects[index].currentSpeed = faebleInstance.grace
	battlerObjects[index].hide()
	battlerObjects[index].position = Vector3(xPos,0,yPos) + gridOffset
	battlerObjects[index].positionIndex = Vector2i(xPos,yPos)
	ChangeTileData(Vector2i(xPos,yPos), "Occupant", battlerObjects[index])
	ChangeTileData(Vector2i(xPos,yPos), "Occupied", true)
	var texture = battlerObjects[index].get_child(0).get_surface_override_material(0)
	texture.albedo_texture = faebleInstance.sprite
	battlerObjects[index].statusBox.ResetStats(faebleInstance)
	battlerObjects[index].show()

func RemoveBattler(battler:Battler):
	battler.hide()
	battler.statusBox.hide()
	battler.faebleEntry = null
	battler.playerControl = false
	battler.statusBox = null
	battler.currentHP = 0
	battler.currentEnergy = 0
	battler.currentSpeed = 0
	ChangeTileData(battler.positionIndex, "Occupant", null)
	ChangeTileData(battler.positionIndex, "Occupied", false)
	battler.positionIndex = Vector2i(-1,-1)
	#battlers.remove_at(polePosition)

func AttachMenu():
	pass #Change parent of command menu, and reset menu states

func ChangeCard():
	pass

func ShowHideCard():
	pass
#endregion

#------------------------------Turn Functions--------------------------------------

#region Turn Functions
func InitOrder(): #Resets speed first, for first turn population
	print("Starting new battle.")
	for battler in battlerObjects:
		if battler.faebleEntry == null:
			continue
		else:
			battler.ResetSpeed()
	PopulateOrder(battlerObjects.duplicate())
	ProgressTurn()
	commandMenu.MenuFlow("Reset")

func PopulateOrder(battlers:Array[Battler]):
	for battler in battlers:
		if battler.faebleEntry == null:
			battlers.erase(battler)
	battlers.sort_custom(SpeedSorter)
	roundOrder = battlers
	for battler in roundOrder:
		print(battler.faebleEntry.name)

func ProgressTurn():
	currentBattler = roundOrder.pop_front()
	if currentBattler != null:
		commandMenu.selectedBattler = currentBattler
		print("It is ", currentBattler.faebleEntry.name, "'s turn.")
	else:
		NewRound()

func NewRound(): #Resets speed after population, to allow prior turn moves to reduce speed
	print("Starting new round.")
	PopulateOrder(battlerObjects.duplicate())
	for battler in roundOrder:
		if battler.faebleEntry == null:
			continue
		else:
			battler.ResetSpeed()
	ProgressTurn()

func SpeedSorter(a:Battler,b:Battler) -> bool:
	if a.currentSpeed > b.currentSpeed:
		return true
	elif a.currentSpeed == b.currentSpeed:
		var coinFlip:int = RandomNumberGenerator.new().randi_range(0,1)
		if coinFlip == 1:
			return true
	return false
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
	ChangeTileData(battler.positionIndex, "Occupant", null)
	ChangeTileData(battler.positionIndex, "Occupied", false)
	commandMenu.hide()
	var distance = abs(location.x - battler.positionIndex.x)*0.3
	if facing != mesh.rotation.y:
		tween.tween_property(mesh, "rotation", Vector3(0,facing,0), 0.3)
	tween.tween_property(battler, "position", (Vector3(location.x,0,battler.positionIndex.y) + gridOffset), distance)
	tween.tween_property(battler, "position", (Vector3(location.x,0,location.y) + gridOffset), 0.2)
	await tween.finished
	commandMenu.position = battler.position + commandMenu.menuOffset
	commandMenu.show()
	battler.positionIndex = location
	print("Facing, after tween: ", mesh.rotation.y)
	ChangeTileData(location, "Occupant", battler)
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
			elif gridDatabase[pos]["Occupant"].playerControl == false and !attack.targetAlly:
				ChangeTileOverlay(pos, "Target")
			elif gridDatabase[pos]["Occupant"].playerControl == true and !attack.targetAlly:
				ChangeTileOverlay(pos, "Block")
			elif gridDatabase[pos]["Occupant"].playerControl == false and attack.targetAlly:
				ChangeTileOverlay(pos, "Block")
			elif gridDatabase[pos]["Occupant"].playerControl == true and attack.targetAlly:
				ChangeTileOverlay(pos, "Target")
		else:
			ChangeTileOverlay(pos, "Range")

func DamageCalc(attacker:Battler, defender:Battler, attack:Skill) -> int: #Returns Outgoing Damage
	var ATB:int = attacker.faebleEntry.tier
	var AHTB:int = ceili(float(attacker.faebleEntry.tier) / 2)
	var DTB:int = defender.faebleEntry.tier
	var DHTB:int = ceili(float(defender.faebleEntry.tier) / 2)
	var damage:int = attack.skillDamage
	var attackerStat:int
	var defenderStat:int
	prints("Initial Damage:", damage, "Attacker Tier:", ATB, "Defender Tier:", DTB)
	if attack.skillNature == "Physical":
		attackerStat = attacker.faebleEntry.brawn + (attacker.brawnStage * stageIncrease)
		defenderStat = defender.faebleEntry.vigor + (attacker.vigorStage * stageIncrease)
	elif attack.skillNature == "Magical":
		attackerStat = attacker.faebleEntry.wit + (attacker.witStage * stageIncrease)
		defenderStat = defender.faebleEntry.ambition + (attacker.ambitionStage * stageIncrease)
	else:
		print("Error! Invalid damage type!")
	
	if attack.skillType == attacker.faebleEntry.sigSchool:
		damage += AHTB
	
	if attackerStat >= defenderStat + 4:
		damage += ATB
	elif attackerStat >= defenderStat + 2:
		damage += AHTB
	elif defenderStat >= attackerStat + 2:
		damage -= DHTB
	elif defenderStat >= attackerStat + 4:
		damage -= DTB
	prints("Post Stats Damage:", damage, "Attacker Stat:", attackerStat, "Defender Stat:", defenderStat)
	
	var matchupMod:int = CheckMatchups(defender.faebleEntry, attack.skillType)
	prints("Matchup Changing by:", matchupMod)
	if matchupMod > 0:
		damage += (matchupMod * ATB)
	if matchupMod < 0:
		damage += (matchupMod * DTB)
	
	print("Final Damage: ", damage)
	return damage

func CheckMatchups(target:Faeble, attackingType:School) -> int: #Returns multiplier int
	var mod:int #Output
	var damageMultiplier:int = 1 #Running tally of adjustment multiplier (affects variable below)
	var damageAdjustment:int = 0 #Running tally of resistance "stage"
	# Import types for defenses
	var firstType:Domain = target.firstDomain 
	var secondType:Domain = target.secondDomain
	var signatureType:School = target.sigSchool
	
	if firstType != null: #Get first type matchup index for attacking type
		if firstType.typeMatchups.has(attackingType):
			damageAdjustment += firstType.typeMatchups[attackingType]
			#print(firstType.name)
	
	if secondType != null: #Get second type matchup index for attacking type
		if secondType.typeMatchups.has(attackingType):
			damageAdjustment += secondType.typeMatchups[attackingType]
			#print(secondType.name)
	
	if signatureType != null: #If the signature school of this monster equals the attacking type, add a step towards resistance
		if attackingType == signatureType:
			damageAdjustment -= 1
	
	if attackingType.name == "Weird" and currentPhase != null: #Increment Weird if any planar phase is present
		damageAdjustment += 1
	elif attackingType.name != "Weird" and currentPhase != null: #If a planar status is present, check for relevency and multiplier/additive adjustment
		if currentPhase.adjustAdditive == true: #If additive, apply to Adjustment
			if currentPhase.typeList.has(attackingType) or currentPhase.allTypes == true:
				damageAdjustment += currentPhase.addPosi
			else:
				damageAdjustment += currentPhase.addNega
			
		if currentPhase.adjustMulti == true: #If multiplicative, apply to multiplier
			if currentPhase.typeList.has(attackingType) or currentPhase.allTypes == true:
				damageMultiplier *= currentPhase.multiPosi
			else:
				damageMultiplier *= currentPhase.multiNega
	
	mod = damageAdjustment * damageMultiplier
	return mod

func LaunchAttack():
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
