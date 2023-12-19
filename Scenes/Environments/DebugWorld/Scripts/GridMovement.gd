extends Node3D

var worldCoords:Vector3i = Vector3i(0,1,0)
@export var currentWorld:Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		CheckMove(Vector2i(1,0))
	elif Input.is_action_just_pressed("ui_left"):
		CheckMove(Vector2i(-1,0))
	elif Input.is_action_just_pressed("ui_down"):
		CheckMove(Vector2i(0,1))
	elif Input.is_action_just_pressed("ui_up"):
		CheckMove(Vector2i(0,-1))

func CheckMove(direction:Vector2i):
	var currentLayer:int = worldCoords.y
	var currentTile:Vector2i = Vector2i(worldCoords.x, worldCoords.z - currentLayer)
	var currentTileData:TileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer, currentTile)
	var targetTile:Vector2i = Vector2i(currentTile.x + direction.x, currentTile.y + direction.y)
	var targetTileData:TileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer, targetTile)
	
	#Insert a for loop to check below tiles until one isn't null
	var belowTile:Vector2i = Vector2i(worldCoords.x, worldCoords.z - (currentLayer-1))
	var belowTileData:TileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer-1, belowTile)
	var belowDistance:int = 1
	while belowTileData == null:
		belowDistance += 1
#		if currentLayer - belowDistance <= 0:
#			break
		belowTile = Vector2i(currentTile.x, currentTile.y - (currentLayer - belowDistance))
		belowTileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer - belowDistance, belowTile)
		if belowDistance >= 3:
			break
	
	var belowTarget:Vector2i = belowTile + direction
	var belowTargetData:TileData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer-1, belowTarget)
	var belowTargetDistance:int = 1
	while belowTargetData == null:
		belowTargetDistance += 1
#		if currentLayer - belowTargetDistance <= 0:
#			break
		belowTarget = Vector2i(targetTile.x, targetTile.y - (currentLayer - belowTargetDistance)) #Something broken here?
		belowTargetData = currentWorld.locationDatabase.get_cell_tile_data(currentLayer - belowTargetDistance, belowTarget)
		if belowTargetDistance >= 3:
			break
	
	var onSlope:bool = false
	var targetBelow:bool = false
	
	if currentTileData == null and belowTileData != null:
		currentTileData = belowTileData
		onSlope = true
	elif belowTileData == null:
		print("Error: Falling!")
		return
	
	if targetTileData == null:
				#Insert edge check code
		if belowTargetData:
			targetTileData = belowTargetData
			targetBelow = true
		else:
			prints(belowTile, belowTarget, "Slope:", currentTileData.get_custom_data("SlopeDir"), "Layer:", currentLayer)
			print("Error: Empty Target!")
			return
	
	var walkable:bool = targetTileData.get_custom_data("Walkable")
	var targetSlopeDir:Vector2i = targetTileData.get_custom_data("SlopeDir")
	var targetHeight:float = targetTileData.get_custom_data("PlayerPos").y
	var currentSlopeDir:Vector2i = currentTileData.get_custom_data("SlopeDir")
	
	if walkable == false:
		print("Blocked!")
		return
	
	prints("Current:", belowTargetDistance)
	
	if targetSlopeDir != Vector2i(0,0):
		if targetBelow == true:
			if targetSlopeDir == -direction:
				position += Vector3(direction.x, 0, direction.y)
				position.y = targetHeight + (currentLayer - belowTargetDistance)
				worldCoords += Vector3i(direction.x, 0, direction.y)
				print("Started walking down slope")
			elif targetSlopeDir == currentSlopeDir:
				position += Vector3(direction.x, 0, direction.y)
				position.y = targetHeight + (currentLayer - 1)
				worldCoords += Vector3i(direction.x, 0, direction.y)
				print("Walking across to parallel slope")
		elif targetSlopeDir == direction:
			position += Vector3(direction.x, 0, direction.y)
			position.y = targetHeight + currentLayer
			worldCoords += Vector3i(direction.x, 1, direction.y)
			print("Started walking up slope")
	elif currentSlopeDir != Vector2i(0,0):
		if targetBelow == true:
			if currentSlopeDir == -direction:
				position += Vector3(direction.x, 0, direction.y)
				if belowTargetDistance >= 2:
					targetHeight += 0.5
				position.y = targetHeight + (currentLayer - belowTargetDistance)
				worldCoords += Vector3i(direction.x, -1, direction.y)
				print("Finished walking down slope")
		elif currentSlopeDir == direction:
			position += Vector3(direction.x, 0, direction.y)
			position.y = targetHeight + currentLayer
			worldCoords += Vector3i(direction.x, 0, direction.y)
			print("Finished walking up slope")
	else:
		position += Vector3(direction.x, 0, direction.y)
		worldCoords += Vector3i(direction.x, 0, direction.y)
	
	#Split up above function into separate tilecheck and movement functions
	#Movement function intakes a "move to" tile ID Vector 3, with boolean for "half height" on slope
	#This function also handles the tweening of any attached sprite from tile center to tile edge, then tile edge to next tile
	
	
#	elif targetSlopeDir != Vector2i(0,0):
#		if targetSlopeDir == direction:
#			position += Vector3(direction.x, 0, direction.y)
#			position.y = targetHeight + currentLayer
#			worldCoords += Vector3i(direction.x, 1, direction.y)
#			print("Walking up slope")
#		elif targetSlopeDir == currentSlopeDir:
#			position += Vector3(direction.x, targetHeight, direction.y)
#			position.y = targetHeight + currentLayer
#			worldCoords += Vector3i(direction.x, 0, direction.y)
#			print("Walking across to parallel slope")
#		else:
#			print("Invalid slope direction, blocked!")
#			prints(direction, targetSlopeDir)
#			return
#	else:
#		position += Vector3(direction.x, 0, direction.y)
#		worldCoords += Vector3i(direction.x, 0, direction.y)
	
	
#	if slopeDir:
#		if slopeDir == direction:
#			position += Vector3(direction.x, 0.5, direction.y)
#			worldCoords += Vector3i(direction.x, 1, direction.y)
#		else:
#			return
#	elif onSlope == true:
#		if slopeDir == direction:
#			position += Vector3(direction.x, 0.5, direction.y)
#			worldCoords += Vector3i(direction.x, 0, direction.y)
#	else:
#		position += Vector3(direction.x, 0, direction.y)
#		worldCoords += Vector3i(direction.x, 0, direction.y)





















#	var inputDir:Vector3
#	if Input.is_action_just_pressed("ui_right"):
#		inputDir.x += 1
#	elif Input.is_action_just_pressed("ui_left"):
#		inputDir.x -= 1
#	elif Input.is_action_just_pressed("ui_down"):
#		inputDir.z += 1
#	elif Input.is_action_just_pressed("ui_up"):
#		inputDir.z -= 1
#	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.z)).normalized()
#
#	if direction:
#		targetPosition = direction
#		print("Before X: ", targetPosition.x / float(gridSize))
#		print("Before Z: ", targetPosition.z / float(gridSize))
#		targetPosition.x = round(targetPosition.x / float(gridSize)) * gridSize
#		print("After X: ", targetPosition.x)
#		targetPosition.z = round(targetPosition.z / float(gridSize)) * gridSize
#		print("After Z: ", targetPosition.z)
#
#
#		position = position + targetPosition

