extends Node3D

@export var stageResource:Stage
@export var stageLayers:Array[Node3D]
@export var layerDepths:Array[float]
@export var layerCount:int = 13
@export var layerSpeed:float = 0.2
@export var FXManager:Node3D

enum Transitions {
	None=0,
	Accordion
}

func _ready():
	await LoadScene(preload("res://Scenes/Environments/World Scenes/Forest/Resources/DeepForest.tres"), Transitions.Accordion)
	await get_tree().create_timer(2.0).timeout
	await LoadScene(preload("res://Scenes/Environments/World Scenes/Forest/Resources/SparseForest.tres"), Transitions.Accordion)
	var spawn = stageResource.faebleGrabBag()
	prints("A wild",spawn.name,"appeared!")


func LoadScene(stage:Stage, transition:int):
	stageResource = stage
	if transition == Transitions.None:
		LayerRetexture()
		ChangeLighting(0.01)
		LayerSpacing(2,1)
	if transition == Transitions.Accordion:
		LayerSpacing(0, 0)
		ChangeLighting(1.0)
		await get_tree().create_timer(1.0).timeout
		LayerRetexture()
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
		prints(stageResource, layer)
		var texture:Material
		texture = layer.get_child(0).get_surface_override_material(0)
		texture.albedo_texture = stageResource.stageLayers[i]
		layer.get_child(0).set_surface_override_material(0, texture)
		print("Assigning Layer: ",i)
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


func ChangeLighting(speed:float):
	var stageLight:SpotLight3D = FXManager.get_child(3)
	var energyTween = get_tree().create_tween()
	var colorTween = get_tree().create_tween()
	energyTween.tween_property(stageLight, "light_energy", stageResource.stageLighting["Energy"], speed)
	colorTween.tween_property(stageLight, "light_color", stageResource.stageLighting["Color"], speed)
