extends Camera3D

@export var camStart:Vector3
@export var camEnd:Vector3
@export var rotateStart:Vector3
@export var rotateEnd:Vector3
@export var pantime:float
@export var player_spot:Node
@export var enemy_spot:Node
@export var shadowbox:Node
@export var highlights:Node
@export var lightbox:Node
@onready var enemy_box_offset = $"../../../Outputs/DisplayManager/EnemyBoxOffset"
@onready var player_box_offset = $"../../../Outputs/DisplayManager/PlayerBoxOffset"



# Called when the node enters the scene tree for the first time.
func _ready():
	#StartupSequence()
	pass

func StartupSequence():
	var tween = get_tree().create_tween()
	var rottween = get_tree().create_tween()
	
	lightbox.show()
	shadowbox.show()
	highlights.hide()
	player_spot.hide()
	enemy_spot.hide()
	player_box_offset.rotation = Vector3(0,deg_to_rad(90),0)
	enemy_box_offset.rotation = Vector3(0,deg_to_rad(-90),0)
	position = camStart
	rotation = Vector3(deg_to_rad(rotateStart.x),deg_to_rad(rotateStart.y),deg_to_rad(rotateStart.z))
	var rottarget = Vector3(deg_to_rad(rotateEnd.x),deg_to_rad(rotateEnd.y),deg_to_rad(rotateEnd.z))
	tween.tween_property(self, "position", camEnd, pantime)
	rottween.tween_property(self, "rotation", rottarget, pantime)
	await get_tree().create_timer(1.5).timeout
	player_spot.show()
	await get_tree().create_timer(0.5).timeout
	enemy_spot.show()
	await get_tree().create_timer(1.0).timeout
	tween = get_tree().create_tween()
	rottween = get_tree().create_tween()
	tween.tween_property(shadowbox, "position", Vector3(-2.752, 3, 0), pantime/2)
	rottween.tween_property(shadowbox, "scale", Vector3(5.555, 0, 2.735), pantime/2)
	await tween.finished
	var stattween1 = get_tree().create_tween()
	var stattween2 = get_tree().create_tween()
	stattween1.tween_property(player_box_offset, "rotation", Vector3(0, 0, 0), 0.3)
	stattween2.tween_property(enemy_box_offset, "rotation", Vector3(0, 0, 0), 0.3)
	await stattween1.finished
	highlights.show()
	lightbox.hide()
	#await field_manager.MoveFaeble(-field_manager.maxDistance/2, false)
	#await field_manager.ChangeDistance(-field_manager.maxDistance/2)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
