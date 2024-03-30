extends Node3D
class_name BattleManager
#BattleManager is responsible for holding universal information, and setting the stage
#Also contains the *actions* for any board or battler changes, but no logic
@export_category("Initialization")
@export var gridDatabase:Dictionary
@export var stageMesh:Node3D
@export var stageSize:Vector2i = Vector2i(9,2)
@export var battlers:Array[Node] #Stores the battler objects for each faebleon the field

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
var roundOrder:Array
#var boardState:String

func _ready():
    PopulateGrid()
    ChangeTileData(Vector2i(2,0), "Occupied", true)
    ChangeTileData(Vector2i(6,0), "Occupied", true)
    ChangeTileData(Vector2i(3,1), "Occupied", true)
    ChangeTileData(Vector2i(5,1), "Occupied", true)
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
                $Commands.moveTaken = true
            if boardState == "Attacking":
                $Commands.attackTaken = true
            
            for grid in gridDatabase:
                ChangeTileOverlay(grid, "Clear")
            selectedGrid = null
            selectedState = ""
            selectedPos = Vector2i(-1,-1)
            $Commands.MenuFlow("Start")
            ChangeBoardState("Waiting")
            print(selectedPos)

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

#------------------------------Grid Functions--------------------------------------

func PopulateGrid():
    #Start grid initialization
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
    #print(gridDatabase) End grid init
    #ChangeTileOverlay(Vector2i(2,0), "Target")
    #ChangeTileOverlay(Vector2i(3,1), "Target")
    #ChangeTileOverlay(Vector2i(6,0), "Block")
    #ChangeTileOverlay(Vector2i(5,1), "Block")
    #Debug testing, replace later with dynamic edit for battlers

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

func AddRemoveBattler():
    pass #Add, remove, or swap the faeble of a battler.

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

func SelectArea(location:Vector2i, range:int, exit=false, allRows:bool=false):
    var gridArea:Array[Vector2i]
    if !gridDatabase[location]["Active"]:
        return
    
    for x in range(-range, range+1): #Add positions to left and right of battler
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
        for x in range(-range+1, range): #Add positions to left and right of battler
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

#------------------------------Movement Functions--------------------------------------

func MoveTo(battler:Battler, location:Vector2i):
    print("Moving!")
    var tween = get_tree().create_tween()
    #Target position offset is x-4.5, y=0.5, z-0.5
    ChangeTileData(battler.positionIndex, "Occupancy", null)
    ChangeTileData(battler.positionIndex, "Occupied", false)
    var distance = abs(location.x - battler.positionIndex.x)*0.3
    tween.tween_property(battler, "position", (Vector3(location.x,0,battler.positionIndex.y) + gridOffset), distance)
    tween.tween_property(battler, "position", (Vector3(location.x,0,location.y) + gridOffset), 0.2)
    await tween.finished
    battler.positionIndex = location
    ChangeTileData(location, "Occupancy", battler)
    ChangeTileData(location, "Occupied", true)

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
        #print(posIndex, "First Pass")
    
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
        #print(posIndex, "Second Pass")
    #Need a part in here that checks for moveblockers, then checks which side moveblocker is on
    #Finally, remove (or prevent appending) any position index > or < than moveblocker posIndex
    for pos in inRange:
        if gridDatabase[pos]["Occupied"] == true:
            ChangeTileOverlay(pos, "Block")
        else:
            ChangeTileOverlay(pos, "Open")

func TakeCost(battler:Battler, amount):
    pass


#------------------------------Battler Functions--------------------------------------

func SwapBattler():
    pass

func MoveBattler():
    pass

func ChangeCard():
    pass

func MoveCard():
    pass #Move in line with battler, hide and pop back up if changing lanes
    #if adjacent to another card on one side, "bump" halfway, if on both sides, bump both
    #Have "BumpOffset" be separate from the actual position value, 

func ShowHideCard():
    pass

#------------------------------Attack Functions--------------------------------------

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
            ChangeTileOverlay(pos, "Target")
        else:
            ChangeTileOverlay(pos, "Range")


#------------------------------Camera Functions--------------------------------------

func ChangeCam():
    pass
