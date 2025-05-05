extends Node3D
class_name CapCameraManager

@export var captureSystem:Node3D
@export var disabled:bool

#External Variables
var faebleSeen:bool #Is the Faeble within the Area Check?
var centerDistance:float #How far from the center of the Faeble is the camera's view?
var overflowFrame:bool #Do opposite cardinal rays connect with the faeble collider?
var propsHit:int #How many obscuring rays are active?
var backdropsHit:int #These work like props, but ADD to score instead of detract
var zoomLevel:float #How zoomed in the camera is

#Setup Variables
@export_category("Camera Movement")
@export var lowBound:Vector3 #Determines left and bottom bounds for cam movement
@export var highBound:Vector3 #Determines right and top bounds
@export var camSpeed:float
@export var captureCam:Camera3D
@export var screenBuffer:Vector2
@export_category("Camera Zoom")
@export var minZoom:float
@export var maxZoom:float
@export var zoomSpeed:float
@export var zoomTime:float
@export var colliderMin:float
@export var colliderMax:float
@export var debugGeo:Mesh


#Internal Variables
@export_category("Internal Variables")
var viewSize:Vector2
@export var centerRay:RayCast3D
@export var cardinalRays:Array[RayCast3D]
@export var colliderArea:Area3D
@onready var targetFaeble:Node3D = $"../../Outputs/PathManager/EnemyBattler" #TEMP
@onready var targetCollider:Area3D = targetFaeble.get_child(0) #TEMP

#Setup Functions
func _ready():
	viewSize = get_viewport().size
	screenBuffer.x = viewSize.x * 0.35
	screenBuffer.y = viewSize.y * 0.25
	get_tree().get_root().size_changed.connect(Resize)
	zoomLevel = -captureCam.position.x# + minZoom
	prints(viewSize, screenBuffer)

#Process Functions
func _input(event): #Move this to CaptureSystem TEMP
	#TEMP eventually replace with smooth zoom
	if disabled:
		return
	var zoomAxis:float = Input.get_axis("ScrollUp", "ScrollDown")
	var zoomFactor:float
	var camTarget:float
	
	if zoomAxis != 0:
		zoomLevel += zoomAxis * zoomSpeed
		zoomLevel = clamp(zoomLevel, minZoom, maxZoom)
		zoomFactor = zoomLevel / (maxZoom - minZoom)
		camTarget = -lerp(minZoom, maxZoom, zoomFactor) + minZoom
		var scaler:float = lerp(colliderMin, colliderMax, zoomFactor - 0.625)
		CamZoom(camTarget, scaler)
	
	if Input.is_action_just_pressed("LeftMouse"):
		faebleSeen = AreaCheck()
		centerDistance = CenterCheck(targetCollider.get_child(0).global_position)
		overflowFrame = OverflowCheck(targetCollider)
		#prints(faebleSeen, centerDistance, overflowFrame)
		if faebleSeen:
			print("Faeble caught in frame!")
		if centerDistance < 0.15:
			print("Faeble is centered!")
		elif centerDistance >= 0.15 and centerDistance < 0.3:
			print("Faeble is almost centered!")
		if overflowFrame:
			print("Faeble is overflowing the frame!")

func _process(delta:float):
	if disabled:
		return
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

#Data-Handling Functions
func Resize():
	viewSize = get_viewport().size
	screenBuffer.x = viewSize.x * 0.35
	screenBuffer.y = viewSize.y * 0.25

func AreaCheck() -> bool:
	var colliders = colliderArea.get_overlapping_areas()
	if colliders.size() > 0:
		#print(colliders)
		return true
	else:
		#print("Nothing Found.")
		return false

func CenterCheck(targetPoint:Vector3) -> float:
	var areaHit:Area3D = centerRay.get_collider()
	if areaHit != null:
		var point = centerRay.get_collision_point()
		#prints(areaHit, target, point)
		return point.distance_to(targetPoint)
	else:
		return 0

func OverflowCheck(targetObject:Area3D) -> bool: #Might change out for collider intersect check
	var raysHit:Array[bool]
	raysHit.resize(cardinalRays.size())
	var index:int = 0
	for ray in cardinalRays:
		var areaHit = ray.get_collider()
		if areaHit != null and areaHit == targetObject:
			raysHit[index] = true
		else:
			raysHit[index] = false
		index += 1
	if raysHit[0] and raysHit[1]:
		return true
	if raysHit[2] and raysHit[3]:
		return true
	return false
	#If opposite cardinal rays connect with the faeble collider, faeble is out of frame.

func PropCheck() -> int:
	#Check faeblecollider if overlapping on layer 4
	pass #Check if faeble collider is touching any prop colliders, no need for rays after all
	return 0



#Tangible Action Functions
func TakePicture():
	faebleSeen = AreaCheck()
	centerDistance = CenterCheck(targetCollider.get_child(0).global_position)
	overflowFrame = OverflowCheck(targetCollider)
	propsHit = PropCheck()

func CamZoom(amount:float, scaler:float):
	var camtween:Tween = get_tree().create_tween()
	var colltween:Tween = get_tree().create_tween()
	camtween.tween_property(captureCam, "position:x", amount, zoomSpeed)
	colltween.tween_property(colliderArea, "scale", Vector3(scaler,scaler,scaler), zoomSpeed)


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
