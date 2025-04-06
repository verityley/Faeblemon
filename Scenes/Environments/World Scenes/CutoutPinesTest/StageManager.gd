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
var playerOffset:float = 0.5
var playerTexture:Texture2D
@export var enemyFaeble:Node3D
var enemyIndex:int
var enemyOffset:float = 1.2
var enemyTexture:Texture2D

@export var maxActiveLayers:int = 11
@export var layerChangeSpeed:float
@export var faebleMoveSpeed:float

func _ready():
	var layerZStart = 4
	var layerZinc = 2
	for pos in range(layerZPositions.size()):
		if pos == 0:
			layerZPositions[pos] = layerZStart
		else:
			layerZPositions[pos] = layerZPositions[pos-1] - layerZinc
	
	LayerRetexture()
	await get_tree().create_timer(2.0).timeout
	LayerReposition()
	await get_tree().create_timer(1.0).timeout
	SetFaebleLayer(true, 2, playerOffset)
	SetFaebleLayer(false, 10, enemyOffset)
	await get_tree().create_timer(1.0).timeout
	
	
	var testAmount:int = 6
	while testAmount > 0:
		await FaebleAdvance(true)
		await get_tree().create_timer(0.4).timeout
		testAmount -= 1
	
	testAmount = 0
	while testAmount > 0:
		await LayerRetreat()
		await get_tree().create_timer(0.2).timeout
		testAmount -= 1

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

func SetFaebleLayer(player:bool, layerIndex:int, offset:float):
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

func MoveFaebleLayer(player:bool, layerIndex:int, offset:float):
	var tween = get_tree().create_tween()
	if player:
		playerFaeble.reparent(activeLayers[layerIndex])
		var target:Vector3 = stageResource.stageLayers[layerIndex+frontLayers.size()].playerAnchor
		prints("Moving to...", target, layerIndex)
		target.y += offset
		tween.tween_property(playerFaeble, "position", target, faebleMoveSpeed)
		playerIndex = layerIndex
	else:
		enemyFaeble.reparent(activeLayers[layerIndex])
		var target:Vector3 = stageResource.stageLayers[layerIndex+frontLayers.size()].enemyAnchor
		target.y += offset
		tween.tween_property(enemyFaeble, "position", target, faebleMoveSpeed)
		enemyIndex = layerIndex

func FaebleAdvance(player:bool):
	if player:
		LayerAdvance()
		await MoveFaebleLayer(player, playerIndex+1, playerOffset)
		prints("Player Layer Index:", playerIndex)
	else:
		LayerRetreat()
		await MoveFaebleLayer(player, enemyIndex-1, enemyOffset)
		prints("Enemy Layer Index:", enemyIndex)

func FaebleRetreat(player:bool):
	pass

func LayerAdvance():
	var firstLayer = activeLayers.pop_front()
	activeLayers.append(firstLayer)
	await LayerReposition()
	playerIndex -= 1
	enemyIndex -= 1

func LayerRetreat():
	var lastLayer = activeLayers.pop_back()
	activeLayers.push_front(lastLayer)
	await LayerReposition()
	playerIndex += 1
	enemyIndex += 1
