extends Node3D

@export var stageResource:Stage

@export var frontLayers:Array[Node3D]
@export var activeLayers:Array[Node3D]
@export var backLayers:Array[Node3D]
@export var layerZPositions:Array[float] = [
	2,1,0,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16
	]

@export var maxActiveLayers:int = 11
@export var layerChangeSpeed:float

func _ready():
	LayerRetexture()
	#await get_tree().create_timer(2.0).timeout
	LayerReposition()
	#await get_tree().create_timer(1.0).timeout
	
	var testAmount:int = 0
	while testAmount > 0:
		await LayerAdvance()
		await get_tree().create_timer(0.1).timeout
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
		texture.albedo_texture = stageResource.layerTextures[i]
		layer.set_surface_override_material(0, texture)
		print("Assigning FrontLayer: ",i)
		i+=1
	
	for layer in activeLayers:
		var texture:Material
		texture = layer.get_surface_override_material(0)
		texture.albedo_texture = stageResource.layerTextures[i]
		layer.set_surface_override_material(0, texture)
		print("Assigning ActiveLayer: ",i)
		i+=1
	
	for layer in backLayers:
		var texture:Material
		texture = layer.get_surface_override_material(0)
		texture.albedo_texture = stageResource.layerTextures[i]
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
		print("Positioning FrontLayer: ",i)
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
		print("Positioning ActiveLayer: ",i)
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
		print("Positioning BackLayer: ",i)
		newOrder.append(layer)
		i+=1
	backLayers = newOrder.duplicate()
	newOrder.clear()
	

func LayerAdvance():
	var firstLayer = activeLayers.pop_front()
	activeLayers.append(firstLayer)
	await LayerReposition()

func LayerRetreat():
	var lastLayer = activeLayers.pop_back()
	activeLayers.push_front(lastLayer)
	await LayerReposition()
