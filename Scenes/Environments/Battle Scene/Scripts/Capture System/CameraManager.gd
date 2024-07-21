extends Node3D

@export var captureSystem:Node3D

#External Variables
var faebleSeen:bool #Is the Faeble within the Area Check?
var centerDistance:float #How far from the center of the Faeble is the camera's view?
var propsHit:int #How many obscuring rays are active?
var backdropsHit:int #These work like props, but ADD to score instead of detract
var zoomLevel:float #How zoomed in the camera is

#Setup Variables
@export var lowBound:Vector3 #Determines left and bottom bounds for cam movement
@export var highBound:Vector3 #Determines right and top bounds
@export var camSpeed:float
@export var captureCam:Camera3D
@export var screenBuffer:Vector2
@export var minZoom:float
@export var maxZoom:float
@export var zoomSpeed:float
@export var zoomTime:float

#Internal Variables
var viewSize

#Setup Functions
func _ready():
	viewSize = get_viewport().size
	screenBuffer.x = viewSize.x * 0.35
	screenBuffer.y = viewSize.y * 0.25
	get_tree().get_root().size_changed.connect(Resize)
	zoomLevel = -captureCam.position.x# + minZoom
	prints(viewSize, screenBuffer)

#Process Functions
func _input(event):
	#TEMP eventually replace with smooth zoom
	var zoomAxis:float = Input.get_axis("ScrollUp", "ScrollDown")
	var zoomFactor:float
	var camTarget:float
	
	if zoomAxis != 0:
		zoomLevel += zoomAxis * zoomSpeed
		zoomLevel = clamp(zoomLevel, minZoom, maxZoom)
		zoomFactor = zoomLevel / (maxZoom - minZoom)
		camTarget = -lerp(minZoom, maxZoom, zoomFactor) + minZoom
		CamZoom(camTarget)
	

func CamZoom(amount:float):
	var camtween:Tween = get_tree().create_tween()
	camtween.tween_property(captureCam, "position:x", amount, zoomSpeed)

func _process(delta:float):
	var inputVector:Vector3 = Vector3.ZERO
	var mousePosition:Vector2 = get_viewport().get_mouse_position()
	var mouseFactor:Vector2
	var target:Vector3
	
	inputVector.z = Input.get_axis("MoveLeft", "MoveRight")
	inputVector.y = Input.get_axis("MoveDown", "MoveUp")
	
	if inputVector != Vector3.ZERO:
		pass #do key/gamepad input
	else: 
		mouseFactor.x = mousePosition.x / viewSize.x
		mouseFactor.y = mousePosition.y / viewSize.y
		target.z = lerp(lowBound.z, highBound.z, mouseFactor.x)
		target.y = lerp(highBound.y, lowBound.y, mouseFactor.y)
	
	captureCam.position.z = clamp(target.z, lowBound.z, highBound.z)
	captureCam.position.y = clamp(target.y, lowBound.y, highBound.y)

func Resize():
	viewSize = get_viewport().size
	screenBuffer.x = viewSize.x * 0.35
	screenBuffer.y = viewSize.y * 0.25

#Data-Handling Functions


#Tangible Action Functions



#placeholder order of operations:
#On ready/setup, set scale of PropCheck to Faeble Scale
#Then get Faeble's center point, ahead of time.
#Finally, activate all objects

#input function, wait for click
#check area, if no faeble then return
#center check, get hit point and compare to faeble center, return distance
#faeble collider area on layer 1
#check prop rays, if any OTHER colliders hit
#if foreground prop, it means the faeble is obscured
#if background prop, it adds to the scene score
#prop colliders on layer 2
#[Insert more camera checks here, if needed]
#Tell picture manager to capture screenshot
#Send data to Capture System
