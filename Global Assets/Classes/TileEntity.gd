extends Node3D
class_name TileEntity

#Position Properties
var worldCoords:Vector3i = Vector3i(position.x, position.y, position.z)
var currentCoords:Vector3i
var targetCoords:Vector3i
var currentTileData:TileData
var targetTileData:TileData
@export var currentWorld:Node

#Movement Properties
@export var moveTime:float = 0.2
@export var canJump:bool
@export var jumpAllowance:int

var isMoving:bool = false
var openInput:bool = false

#Occupying Properties
@export var takesSpace:bool
@export var wallHack:bool
@export var ignoresSlopes:bool

#Interaction Properties
@export var interactable:bool
@export var interactionNode:Node #Assign to a node with events to run when interacted with.

func CheckTarget(direction:Vector2i) -> bool: #Assigns tile data based on direction from current tile.
	var currentLayer:int = worldCoords.y
	var currentTile:Vector2i = Vector2i(worldCoords.x, worldCoords.z - currentLayer)
	currentTileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer, currentTile)
	#print("Current Tile Coords: ", currentTile, "Layer: ", currentLayer)
	
	var targetDistance:int = 0
	var onSlope:bool = false
	
	if currentTileData == null: #This only happens if I'm on a slope.
		currentTileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer-1, Vector2i(currentTile.x, currentTile.y+1))
		onSlope == true
		if currentTileData == null:
			print("Error, no tile beneath tile entity.")
			return false
	
	
	var targetTile:Vector2i = Vector2i(currentTile.x + direction.x, currentTile.y + direction.y)
	#print("Target Tile Coords: ", targetTile, "Layer: ", currentLayer)
	targetTileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer, targetTile)
	
	if targetTileData == null:
		print("No tile at target, looping below until found.")
		while targetTileData == null:
			targetDistance += 1
			targetTile = Vector2i(targetTile.x, targetTile.y + 1)
			targetTileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer - targetDistance, targetTile)
			#print("New target tile Coords: ", targetTile, "Layer: ", currentLayer - targetDistance)
			if targetDistance >= 4:
				print("Too far to check, cancelling.")
				targetTile = Vector2i(currentTile.x + direction.x, currentTile.y + direction.y)
				targetTileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer, targetTile)
				targetDistance = 0
				return false
		
	
	currentCoords = Vector3i(currentTile.x, currentLayer, currentTile.y)
	targetCoords = Vector3i(targetTile.x, currentLayer - targetDistance, targetTile.y)
	#prints(currentCoords, targetCoords)
	return true


func MoveByDirection(direction:Vector2i):
	if targetTileData == null:
		return
	
	var walkable:bool = targetTileData.get_custom_data("Walkable")
	var targetSlopeDir:Vector2i = targetTileData.get_custom_data("SlopeDir")
	var targetHeight:float = targetTileData.get_custom_data("TargetPos").y
	var currentSlopeDir:Vector2i = currentTileData.get_custom_data("SlopeDir")
	var targetBelow:bool
	
	var currentLayer:int = currentCoords.y
	var targetDistance:int = currentCoords.y - targetCoords.y
	#print("Drop distance: ", targetDistance)
	if targetDistance > 0:
		targetBelow = true
		if targetDistance > 2:
			print("Too steep, need to jump! No slope to land on.")
			return
		elif targetDistance == 2 and currentSlopeDir == Vector2i(0,0):
			print(currentSlopeDir)
			print("Too steep, need to jump!")
			return
		elif targetDistance == 1 and currentSlopeDir == Vector2i(0,0) and targetSlopeDir == Vector2i(0,0):
			print(currentSlopeDir)
			print("Too steep, but this is safe to jump!")
			return #Eventually replace with jump function
	var slopeStep:int = 0
	
	if targetSlopeDir != Vector2i(0,0):
		slopeStep = 1
	
	if walkable == false:
		print("Blocked!")
		return
	
	
	#BEGIN Movement Allowances:
	var currentMatches:bool
	if (currentSlopeDir.x == direction.x and direction.x != 0) or (currentSlopeDir.y == direction.y and direction.y != 0):
		currentMatches = true
	var targetMatches:bool
	if (targetSlopeDir.x == direction.x and direction.x != 0) or (targetSlopeDir.y == direction.y and direction.y != 0):
		targetMatches = true
	var negativeMatches:bool
	if (currentSlopeDir.x == -direction.x and direction.x != 0) or (currentSlopeDir.y == -direction.y and direction.y != 0):
		negativeMatches = true
	var negTargetMatches:bool
	if (targetSlopeDir.x == -direction.x and direction.x != 0) or (targetSlopeDir.y == -direction.y and direction.y != 0):
		negTargetMatches = true
	
	var slopeMatches:bool
	if (currentSlopeDir.x == targetSlopeDir.x and targetSlopeDir.x != 0) or (currentSlopeDir.y == targetSlopeDir.y and targetSlopeDir.y != 0):
		slopeMatches = true
	
	var targetMatchesZero:bool
	if targetSlopeDir == Vector2i(0,0):
		targetMatchesZero = true
	
	
	if (targetMatches and !targetBelow) \
	#Direction matches slope entry from ground.
	
	or (negTargetMatches and targetBelow) \
	#Direction matches reverse slope entry from top.
	
	or (slopeMatches and currentSlopeDir != Vector2i(0,0)) \
	#Slopes are equal/parallel, not on flat ground.
	
	or (negativeMatches and targetMatchesZero and targetBelow) \
	#Direction matches slope exit to ground.
	
	or (currentMatches and targetMatchesZero and !targetBelow) \
	#Direction matches slope exit to top.
	
	or (currentSlopeDir == Vector2i(0,0) and targetMatchesZero and !targetBelow):
	#Moving from flat ground to flat ground.
	
	#END Movement Allowances
		#Enact movement animation/positioning and update world coordinates to match.
		isMoving = true
		
		worldCoords = Vector3i(targetCoords.x, targetCoords.y + slopeStep, targetCoords.z + (currentLayer - targetDistance))
		#print("Coords: ", worldCoords)
		var tween = get_tree().create_tween()
		var targetPosition:Vector3 = Vector3(targetCoords.x, targetCoords.y + targetHeight, targetCoords.z + (currentLayer - targetDistance))
		var halfwayOffsetY:float = 0
		if targetBelow and targetSlopeDir != Vector2i(0,0):
			halfwayOffsetY = 1
		if slopeMatches and currentCoords.y-1 == targetCoords.y:
			halfwayOffsetY = targetHeight
		
		var halfwayPoint:Vector3 = Vector3(float(targetCoords.x) - (float(direction.x)/2), float(targetCoords.y) + halfwayOffsetY, float(targetCoords.z + (currentLayer - targetDistance)) - (float(direction.y)/2))
		if direction.length() > 1:
			tween.tween_property(self, "position", halfwayPoint, moveTime*1.5/2)
			tween.tween_property(self, "position", targetPosition, moveTime*1.5/2)
		else:
			tween.tween_property(self, "position", halfwayPoint, moveTime/2)
			tween.tween_property(self, "position", targetPosition, moveTime/2)
		await tween.finished
		isMoving = false
		#tween.tween_callback(self.queue_free)
		
		#print("Position: ", position)
	
	



func PathfindToPosition():
	pass

func Interact():
	pass

func InteractedWith():
	pass
