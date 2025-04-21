extends Node3D

@export var stageResource:Stage

@export var frontLayers:Array[Node3D]
@export var activeLayers:Array[Node3D]
@export var backLayers:Array[Node3D]
@export var layerZPositions:Array[float] = [
	2,1,0,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16
	]

@export var playerFaeble:Node3D
var playerIndex:int
var playerOffset:float = 0
var playerTexture:Texture2D
@export var enemyFaeble:Node3D
var enemyIndex:int
var enemyOffset:float = 0
var enemyTexture:Texture2D

var distance:int

@export var maxActiveLayers:int = 7
@export var layerChangeSpeed:float
@export var faebleMoveSpeed:float
@export var layerIncrement:int = 3

@export var jumpHeight:float = 0.5
@export var playerPosition:Vector3
@export var enemyPosition:Vector3

func _ready():
	var layerZStart = 6
	for pos in range(layerZPositions.size()):
		if pos == 0:
			layerZPositions[pos] = layerZStart
		else:
			layerZPositions[pos] = layerZPositions[pos-1] - layerIncrement
	
	LayerRetexture()
	await get_tree().create_timer(2.0).timeout
	LayerReposition()
	await get_tree().create_timer(1.0).timeout
	FaebleReposition(true, 0, playerOffset)
	FaebleReposition(false, 6, enemyOffset)
	distance = abs(playerIndex - enemyIndex)
	await get_tree().create_timer(1.0).timeout
	
	
	var testAmount:int = 4
	while testAmount > 0:
		await FaebleAdvance(true)
		await get_tree().create_timer(faebleMoveSpeed).timeout
		testAmount -= 1
	print(distance)
	testAmount = 8
	while testAmount > 0:
		await FaebleAdvance(false)
		await get_tree().create_timer(faebleMoveSpeed).timeout
		testAmount -= 1
	print(distance)


func LayerRetexture():
	var i:int = 0
	for layer in frontLayers:
		var texture:Material
		texture = layer.get_surface_override_material(0)
		prints(stageResource.stageLayers[i] , stageResource.stageLayers[i].layerTexture)
		texture.albedo_texture = stageResource.stageLayers[i].layerTexture
		layer.set_surface_override_material(0, texture)
		print("Assigning FrontLayer: ",i)
		i+=1
	
	for layer in activeLayers:
		var texture:Material
		texture = layer.get_surface_override_material(0)
		prints(stageResource.stageLayers[i] , stageResource.stageLayers[i].layerTexture)
		texture.albedo_texture = stageResource.stageLayers[i].layerTexture
		layer.set_surface_override_material(0, texture)
		print("Assigning ActiveLayer: ",i)
		i+=1
	
	for layer in backLayers:
		var texture:Material
		texture = layer.get_surface_override_material(0)
		prints(stageResource.stageLayers[i] , stageResource.stageLayers[i].layerTexture)
		texture.albedo_texture = stageResource.stageLayers[i].layerTexture
		layer.set_surface_override_material(0, texture)
		print("Assigning BackLayer: ",i)
		i+=1

func LayerReposition():
	var newOrder:Array[Node3D]
	var i:int = 0
	for layer in frontLayers:
		var target:Vector3 = Vector3(0,0,layerZPositions[i])
		var tween = get_tree().create_tween()
		tween.tween_property(layer, "position", target, 0.2)
		#await tween.finished
		#layer.position = target
		#print("Positioning FrontLayer: ",i)
		newOrder.append(layer)
		i+=1
	frontLayers = newOrder.duplicate()
	newOrder.clear()
	for layer in activeLayers:
		var target:Vector3 = Vector3(0,0,layerZPositions[i])
		var tween = get_tree().create_tween()
		tween.tween_property(layer, "position", target, 0.2)
		#await tween.finished
		#layer.position = target
		#print("Positioning ActiveLayer: ",i)
		newOrder.append(layer)
		i+=1
	activeLayers = newOrder.duplicate()
	newOrder.clear()
	for layer in backLayers:
		var target:Vector3 = Vector3(0,0,layerZPositions[i])
		var tween = get_tree().create_tween()
		tween.tween_property(layer, "position", target, 0.2)
		#await tween.finished
		#layer.position = target
		#print("Positioning BackLayer: ",i)
		newOrder.append(layer)
		i+=1
	backLayers = newOrder.duplicate()
	newOrder.clear()
	

func ChangeFaebleTexture(player:bool, faebleTexture:Texture2D):
	pass

func FaebleReposition(player:bool, layerIndex:int, offset:float):
	if player:
		playerFaeble.reparent(activeLayers[layerIndex])
		playerFaeble.position.z = -1
		#playerFaeble.position.y = offset
		playerIndex = layerIndex
	else:
		enemyFaeble.reparent(activeLayers[layerIndex])
		enemyFaeble.position.z = -1
		#enemyFaeble.position.y = offset
		enemyIndex = layerIndex

func FaeblePointReposition(player:bool, layerIndex:int, offset:float):
	if player:
		playerFaeble.reparent(activeLayers[layerIndex])
		playerFaeble.position = stageResource.stageLayers[layerIndex+frontLayers.size()].playerAnchor
		playerFaeble.position.y += offset
		playerIndex = layerIndex
	else:
		enemyFaeble.reparent(activeLayers[layerIndex])
		enemyFaeble.position = stageResource.stageLayers[layerIndex+frontLayers.size()].enemyAnchor
		enemyFaeble.position.y += offset
		enemyIndex = layerIndex

func FaebleMove(player:bool, direction:int, offset:float):
	var tween = get_tree().create_tween()
	if player:
		#playerFaeble.reparent(get_tree().root)
		var target:Vector3 =  Vector3(playerFaeble.position.x,playerFaeble.position.y,direction)
		var jumpTarget = target + Vector3(0, jumpHeight, direction/2)
		prints("Moving to...", target, jumpTarget, direction)
		tween.tween_property(playerFaeble, "position", jumpTarget, faebleMoveSpeed/2)
		tween.tween_property(playerFaeble, "position", target, faebleMoveSpeed/2)
		
		
	else:
		var target:Vector3 = enemyFaeble.position + Vector3(0,0,direction)
		prints("Moving to...", target, direction)
		var jumpTarget = lerp(enemyFaeble.position, target, 0.5) + Vector3(0,jumpHeight,0)
		tween.tween_property(enemyFaeble, "position", jumpTarget, faebleMoveSpeed/2)
		tween.tween_property(enemyFaeble, "position", target, faebleMoveSpeed/2)

func FaeblePointMove(player:bool, layerIndex:int, offset:float):
	var tween = get_tree().create_tween()
	if player:
		playerFaeble.reparent(activeLayers[layerIndex])
		var target:Vector3 = stageResource.stageLayers[layerIndex+frontLayers.size()].playerAnchor
		prints("Moving to...", target, layerIndex)
		target.y += offset
		var jumpTarget = lerp(playerFaeble.position, target, 0.5) + Vector3(0,jumpHeight,0)
		tween.tween_property(playerFaeble, "position", jumpTarget, faebleMoveSpeed/2)
		tween.tween_property(playerFaeble, "position", target, faebleMoveSpeed/2)
	else:
		enemyFaeble.reparent(activeLayers[layerIndex])
		var target:Vector3 = stageResource.stageLayers[layerIndex+frontLayers.size()].enemyAnchor
		target.y += offset
		var jumpTarget = lerp(enemyFaeble.position, target, 0.5) + Vector3(0,jumpHeight,0)
		tween.tween_property(enemyFaeble, "position", jumpTarget, faebleMoveSpeed/2)
		tween.tween_property(enemyFaeble, "position", target, faebleMoveSpeed)

func FaebleAdvance(player:bool):
	if player:
		if distance-1 >= 0:
			LayerAdvance()
			await FaebleMove(player, -1, playerOffset)
			playerIndex += 1
			playerFaeble.reparent(activeLayers[playerIndex])
			distance -= 1
			prints("Player Layer Index:", playerIndex)
		else:
			print("Player has reached minimum distance and cannot advance further.")
	else:
		if distance-1 >= 0:
			#LayerRetreat()
			await FaebleMove(player, 1, enemyOffset)
			prints("Enemy Layer Index:", enemyIndex)
			enemyIndex -= 1
			enemyFaeble.reparent(activeLayers[enemyIndex])
			distance -= 1
		else:
			print("Enemy has reached minimum distance and cannot advance further.")

func FaebleRetreat(player:bool):
	if player:
		#LayerRetreat()
		await FaebleMove(player, playerIndex-1, playerOffset)
		prints("Player Layer Index:", playerIndex)
		playerIndex -= 1
	else:
		#LayerAdvance()
		await FaebleMove(player, enemyIndex+1, enemyOffset)
		prints("Enemy Layer Index:", enemyIndex)
		enemyIndex += 1

func LayerAdvance():
	var firstLayer = activeLayers.pop_front()
	activeLayers.append(firstLayer)
	await LayerReposition()


func LayerRetreat():
	var lastLayer = activeLayers.pop_back()
	activeLayers.push_front(lastLayer)
	await LayerReposition()
