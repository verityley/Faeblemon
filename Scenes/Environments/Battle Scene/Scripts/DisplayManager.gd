extends Node3D

@export var battleManager:Node3D

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
func ChangeCurrent(resource:int, amount:int, player:bool): #Does not work for Action Points
	if resource == Resources.Actions:
		print("Actions max can't be changed.") #Might change for status effects?
		return
	var targetBoxes:Array
	var halfResource:Mesh
	var fullResource:Mesh
	if player:
		match resource:
			Resources.Health:
				targetBoxes = phBoxes
				halfResource = halfHeart
				fullResource = fullHeart
			Resources.Resolve:
				targetBoxes = prBoxes
				halfResource = halfResolve
				fullResource = fullResolve
			Resources.Mana:
				targetBoxes = pmBoxes
				halfResource = halfMana
				fullResource = fullMana
	else:
		match resource:
			Resources.Health:
				targetBoxes = ehBoxes
				halfResource = halfHeart
				fullResource = fullHeart
			Resources.Resolve:
				targetBoxes = erBoxes
				halfResource = halfResolve
				fullResource = fullResolve
			Resources.Mana:
				targetBoxes = emBoxes
				halfResource = halfMana
				fullResource = fullMana
	
	#After resource declaration, show/hide blockers in array
	var tally:int = amount
	for box in targetBoxes:
		#box.show()
		#Insert Health exception for quarters, tally for 1,2,3
		if tally == 1:
			box.mesh = halfResource
			tally -= 1
		elif tally == 0:
			#box.hide()
			box.mesh = null
		else:
			box.mesh = fullResource
			tally -= 2
	

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
