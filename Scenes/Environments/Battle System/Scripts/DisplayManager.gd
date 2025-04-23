extends Node3D
class_name DisplayManager

@export var battleSystem:BattleSystem

#External Variables

#Setup Variables
@export var playerPlate:Node3D
@export var enemyPlate:Node3D

@export var halfHeart:Mesh
@export var fullHeart:Mesh
@export var halfResolve:Mesh
@export var fullResolve:Mesh
@export var halfMana:Mesh
@export var halfMaxMana:Mesh
@export var fullMana:Mesh
@export var blockerMaterial:Material

@export var animTime:float = 0.15

#Internal Variables
@onready var phBoxes:Array[Node] = playerPlate.get_child(0).get_children()
@onready var prBoxes:Array[Node] = playerPlate.get_child(1).get_children()
@onready var pmBoxes:Array[Node] = playerPlate.get_child(2).get_children()
@onready var paBoxes:Array[Node] = playerPlate.get_child(3).get_children()
@onready var ehBoxes:Array[Node] = enemyPlate.get_child(0).get_children()
@onready var erBoxes:Array[Node] = enemyPlate.get_child(1).get_children()
@onready var emBoxes:Array[Node] = enemyPlate.get_child(2).get_children()
@onready var eaBoxes:Array[Node] = enemyPlate.get_child(3).get_children()

enum Resources {
Health = 0,
Resolve,
Mana,
Actions
}


#Setup Functions
func _ready():
	pass

#Data-Handling Functions
func ChangeMax(resource:int, max:int, player:bool):
	if resource == Resources.Actions:
		print("Actions max can't be changed.") #Might change for status effects?
		return
	var targetBoxes:Array
	var halfResource:Mesh
	var fullResource:Mesh
	var flip:int = 1
	if player:
		match resource:
			Resources.Health:
				targetBoxes = phBoxes
				halfResource = halfHeart
				fullResource = fullHeart
				flip = -1.01
			Resources.Resolve:
				targetBoxes = prBoxes
				halfResource = halfResolve
				fullResource = fullResolve
				flip = -1.01
			Resources.Mana:
				targetBoxes = pmBoxes
				halfResource = halfMaxMana
				fullResource = fullMana
				flip = 1.01
	else:
		match resource:
			Resources.Health:
				targetBoxes = ehBoxes
				halfResource = halfHeart
				fullResource = fullHeart
				flip = -1.01
			Resources.Resolve:
				targetBoxes = erBoxes
				halfResource = halfResolve
				fullResource = fullResolve
				flip = -1.01
			Resources.Mana:
				targetBoxes = emBoxes
				halfResource = halfMaxMana
				fullResource = fullMana
				flip = 1.01
	
	#After resource declaration, show/hide blockers in array
	var tally:int = max
	for box in targetBoxes:
		var blocker:MeshInstance3D = box.get_child(0)
		blocker.show()
		blocker.scale.z = 1.01 #TEMP, replace with variable
		if tally == 1:
			blocker.mesh = halfResource
			blocker.scale.z = flip
			tally -= 1
		elif tally == 0:
			blocker.mesh = fullResource
		else:
			blocker.hide()
			tally -= 2
		blocker.set_surface_override_material(0, blockerMaterial)
	

#Tangible Action Functions
func ChangeCurrent(resource:int, amount:int, player:bool, animate:bool=false): #Does not work for Action Points
	if resource == Resources.Actions:
		print("Actions max can't be changed.") #Might change for status effects?
		return
	var targetBoxes:Array
	var halfResource:Mesh
	var fullResource:Mesh
	var deplete:bool = false
	if player:
		match resource:
			Resources.Health:
				if amount < battleSystem.pHealth:
					deplete = true
				targetBoxes = phBoxes
				halfResource = halfHeart
				fullResource = fullHeart
			Resources.Resolve:
				if amount < battleSystem.pResolve:
					deplete = true
				targetBoxes = prBoxes
				halfResource = halfResolve
				fullResource = fullResolve
			Resources.Mana:
				if amount < battleSystem.pMana:
					deplete = true
				targetBoxes = pmBoxes
				halfResource = halfMana
				fullResource = fullMana
	else:
		match resource:
			Resources.Health:
				if amount < battleSystem.eHealth:
					deplete = true
				targetBoxes = ehBoxes
				halfResource = halfHeart
				fullResource = fullHeart
			Resources.Resolve:
				if amount < battleSystem.eResolve:
					deplete = true
				targetBoxes = erBoxes
				halfResource = halfResolve
				fullResource = fullResolve
			Resources.Mana:
				if amount < battleSystem.eMana:
					deplete = true
				targetBoxes = emBoxes
				halfResource = halfMana
				fullResource = fullMana
	
	#After resource declaration, show/hide blockers in array
	var tally:int = amount
	var animBoxes:Array[Node3D]
	var animResources:Array[Mesh]
	var animHalf:Array[bool]
	for box in targetBoxes:
		#box.show()
		#box.mesh = fullResource
		#Insert Health exception for quarters, tally for 1,2,3
		if tally == 1:
			tally -= 1
			if !box.get_child(0).visible and animate:
				animBoxes.append(box)
				animResources.append(halfResource)
				animHalf.append(true)
			else:
				box.mesh = halfResource
		elif tally == 0:
			#box.hide()
			if !box.get_child(0).visible and animate and deplete:
				animBoxes.append(box)
				animResources.append(null)
				animHalf.append(false)
				#await AnimateChange(box, null, deplete, false)
			else:
				box.mesh = null
		else:
			tally -= 2
			if !box.get_child(0).visible and animate and !deplete and box.mesh != fullResource:
				animBoxes.append(box)
				animResources.append(fullResource)
				if box.mesh == halfResource:
					animHalf.append(true)
				else:
					animHalf.append(false)
				#await AnimateChange(box, fullResource, deplete, false)
			else:
				box.mesh = fullResource
	if deplete:
		animBoxes.reverse()
		animResources.reverse()
		animHalf.reverse()
	for i in range(animBoxes.size()):
		await AnimateChange(animBoxes[i], animResources[i], deplete, animHalf[i])
	

func ChangeActions(amount:int, player:bool):
	var tally:int = amount
	var targetBoxes:Array
	if player:
		targetBoxes = paBoxes
	else:
		targetBoxes = eaBoxes
	for box in targetBoxes:
		box.show()
		if tally != 0:
			box.show()
			tally -= 1
		else:
			box.hide()

func AnimateChange(container:Node3D, resource, deplete:bool, half:bool):
	var tween = get_tree().create_tween()
	var target:Vector3
	#var animContainer = container.duplicate()
	#add_child(animContainer)
	#container.hide()
	var tempContainer:Node3D
	if deplete:
		if half:
			tempContainer = MeshInstance3D.new()
			add_child(tempContainer)
			tempContainer.global_position = container.global_position
			tempContainer.mesh = resource
		#print("Depleting")
		target = container.position + Vector3(0,0,0.7)
		tween.tween_property(container, "position", target, animTime)
		await tween.finished
		container.mesh = resource
		container.position  -= Vector3(0,0,0.7)
	else:
		#print("Regaining")
		tempContainer = MeshInstance3D.new()
		add_child(tempContainer)
		tempContainer.global_position = container.global_position
		tempContainer.mesh = container.mesh
		container.mesh = resource
		target = container.position
		container.position += Vector3(0,0,0.7)
		tween.tween_property(container, "position", target, animTime)
		await tween.finished
	if tempContainer != null:
		tempContainer.queue_free()
	#container.show()
	#animContainer.queue_free()
