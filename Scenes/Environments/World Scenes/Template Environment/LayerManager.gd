extends Node3D

@export var stageResource:Stage
@export var stageLayers:Array[Node3D]
@export var layerDepths:Array[float]
@export var layerCount:int = 13
@export var layerSpeed:float = 0.2



func _ready():
	LayerSpacing(0, 0)
	await get_tree().create_timer(1.0).timeout
	LayerSpacing(2, 1)


func LayerSpacing(start:float, spacing:float):
	for pos in range(layerDepths.size()):
		if pos == 0:
			layerDepths[pos] = start
		else:
			layerDepths[pos] = layerDepths[pos-1] - spacing
	LayerReposition()


func LayerRetexture():
	var i:int = 0
	for layer in stageLayers:
		var texture:Material
		texture = layer.get_surface_override_material(0)
		prints(stageResource.stageLayers[i] , stageResource.stageLayers[i].layerTexture)
		texture.albedo_texture = stageResource.stageLayers[i].layerTexture
		layer.set_surface_override_material(0, texture)
		print("Assigning FrontLayer: ",i)
		i+=1


func LayerReposition():
	var newOrder:Array[Node3D]
	var i:int = 0
	for layer in stageLayers:
		var target:Vector3 = Vector3(0,0,layerDepths[i])
		target.x = layer.position.x
		target.y = layer.position.y
		var tween = get_tree().create_tween()
		tween.tween_property(layer, "position", target, layerSpeed)
		#await tween.finished
		#layer.position = target
		#print("Positioning FrontLayer: ",i)
		newOrder.append(layer)
		i+=1
	stageLayers = newOrder.duplicate()
	newOrder.clear()
