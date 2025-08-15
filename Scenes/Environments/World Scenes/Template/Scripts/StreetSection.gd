extends Node3D
@export var overworldManager:OverworldManager

@export var MapBlocks:Array[Node3D]
@export var streetCam:Node3D

var camLock:bool

func _physics_process(delta: float) -> void:
	if camLock:
		streetCam.global_position.x = overworldManager.player.global_position.x

func AllFront(body, show:bool=false):
	print("Street Trigger Entry")
	for block in MapBlocks:
		block.SlideFront(show)

func AllBack(body, show:bool=false):
	print("Street Trigger Entry")
	for block in MapBlocks:
		block.SlideBack(show)

func CameraLock(_body=null):
	camLock = true
	streetCam.global_position.x = overworldManager.player.global_position.x
	overworldManager.camera.camTarget = streetCam

func CameraUnlock(_body=null):
	camLock = false
	overworldManager.camera.camTarget = overworldManager.player.playerCam
