extends Node3D
class_name StageSystem

@export var stageResource:Stage
@export var stageLayers:Array[Node3D]
@export var layerDepths:Array[float]
@export var layerParallax:Array[float]
@export var layerHidden:Array[bool]
@export var layerCount:int = 13
@export var layerSpeed:float = 0.2
@export var parallaxSpeed:float = 0.4
@export var FXManager:Node3D
@export var stageCamera:Camera3D
@export var startPos:float = 2.0
@export var defaultSpacing:float = 1.5
@export var hidepoint:float = -15.0

enum Transitions {
	None=0,
	Accordion
}


func _ready():
	EventBus.connect("FaebleMoved",ChangeRange)
	pass


func LoadScene(stage:Stage, transition:int):
	stageResource = stage
	layerDepths.clear()
	layerParallax.clear()
	for layer in range(layerCount):
		layerDepths.append(0.0)
		layerParallax.append(0.0)
		layerHidden.append(false)
	if transition == Transitions.None:
		LayerRetexture()
		await get_tree().create_timer(0.5).timeout
		ChangeLighting(0.01)
		LayerSpacing(defaultSpacing)
	if transition == Transitions.Accordion:
		LayerSpacing(0, 0)
		ChangeLighting(1.0)
		await get_tree().create_timer(1.0).timeout
		LayerRetexture()
		LayerSpacing(defaultSpacing)


func LayerSpacing(spacing:float,altSpeed:float=0.0, startOffset:float=0.0):
	for pos in range(layerDepths.size()):
		if pos == 0:
			layerDepths[pos] = startPos + startOffset
		elif pos != 0 and layerHidden[pos] == true:
			#layerDepths[pos] = start - (spacing*layerCount)
			pass
		else:
			var previous:int = pos-1
			if layerHidden[previous] == true:
				for i in range(previous,-1,-1):
					if layerHidden[i] == false:
						break
					else:
						previous -= 1
			layerDepths[pos] = layerDepths[previous] - spacing
	if altSpeed == 0.0:
		LayerReposition(layerSpeed)
	else:
		LayerReposition(altSpeed)


func LayerShifting(spacing:float, exponent:float=0.0, altSpeed:float=0.0, startOffset:float=0.0):
	for pos in range(layerParallax.size()):
		if pos == 0:
			layerParallax[pos] = startOffset
		elif pos != 0 and layerHidden[pos] == true:
			#layerDepths[pos] = start - (spacing*layerCount)
			continue
		else:
			var previous:int = pos-1
			if layerHidden[previous] == true:
				for i in range(previous,-1,-1):
					if layerHidden[i] == false:
						break
					else:
						previous -= 1
			if startOffset != 0.0:
				layerParallax[pos] = layerParallax[previous] - (spacing * (pos * exponent)) - (startOffset/pos)
			else:
				layerParallax[pos] = layerParallax[previous] - (spacing * (pos * exponent))
	if altSpeed == 0.0:
		LayerReposition(parallaxSpeed)
	else:
		LayerReposition(altSpeed)



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


func LayerReposition(speed:float):
	#var newOrder:Array[Node3D]
	var i:int = 0
	for layer in stageLayers:
		var target:Vector3 = Vector3(layerParallax[i],0,layerDepths[i])
		#target.x = layer.position.x
		if layerHidden[i] == true:
			target.y = layer.position.y + hidepoint
		elif layerHidden[i] == false and layer.position.y < 0.0:
			target.y = 0.0
		else:
			target.y = layer.position.y
		var tween = get_tree().create_tween()
		tween.tween_property(layer, "position", target, speed)
		#if layerHidden[i] == true:
			#layer.hide()
		#else:
			#layer.show()
		#await tween.finished
		#layer.position = target
		#print("Positioning FrontLayer: ",i)
		#newOrder.append(layer)
		i+=1
	#stageLayers = newOrder.duplicate()
	#newOrder.clear()


func LayerHide(index:int, hidden:bool, update:bool=false):
	if layerHidden[index] == hidden:
		print("Already correctly shown, skipping.")
	layerHidden[index] = hidden
	if update:
		LayerSpacing(defaultSpacing)


func ChangeLighting(speed:float):
	var stageLight:SpotLight3D = FXManager.get_child(3)
	var energyTween = get_tree().create_tween()
	var colorTween = get_tree().create_tween()
	energyTween.tween_property(stageLight, "light_energy", stageResource.stageLighting["Energy"], speed)
	colorTween.tween_property(stageLight, "light_color", stageResource.stageLighting["Color"], speed)


func ChangeRange(range:Enums.Ranges):
	#print("Changing 3D Range")
	match range:
		Enums.Ranges.Melee:
			LayerHide(5,true)
			LayerHide(6,true)
			LayerHide(7,true)
			LayerHide(8,true,true)
			LayerShifting(0.0)
		Enums.Ranges.Near:
			LayerHide(5,true)
			LayerHide(6,true)
			LayerHide(7,false)
			LayerHide(8,false,true)
			LayerShifting(-0.1, 0.2)
		Enums.Ranges.Far:
			LayerHide(5,false)
			LayerHide(6,false)
			LayerHide(7,false)
			LayerHide(8,false,true)
			LayerShifting(-0.25, 0.2)
	#sceneRange = range
