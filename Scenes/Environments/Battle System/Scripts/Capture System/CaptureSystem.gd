extends Node3D
class_name CaptureSystem

#External Variables
var wildFaeble:Faeble
var faebleObject:Node3D


#Setup Variables
@export_category("Managers")
@export var cameraManager:CapCameraManager
@export var behaviorManager:CapBehaviorManager
@export var pathManager:CapPathManager

#Score weights are the max a score can be, divide target and actual value, lerp score to weight
@export_category("Score Weights")
@export var maxCapChance:int = 100
@export var centerScoreWeight:int = 20
@export var zoomScoreWeight:int = 20
@export var propScoreWeight:int = 10
@export var overflowScoreWeight:int = -10
@export var blockingScoreWeight:int = -10

@export var centerMax:float = 0.3
#Internal Variables



#Setup Functions


#Process Functions


#Data-Handling Functions
func ScorePicture() -> int:
	if cameraManager.faebleSeen == false:
		return -100
	var score:int
	#CenterCheck
	var dis:float = cameraManager.centerDistance
	if dis <= centerMax:
		var disFactor:float = 1 - (dis / centerMax)
		score += lerp(centerScoreWeight, 0, disFactor)
		print(score)
	cameraManager.overflowFrame = false
	cameraManager.centerDistance = 0
	cameraManager.propsHit = 0
	cameraManager.backdropsHit = 0
	cameraManager.zoomLevel
	return score

func RNGCheck(score:int):
	pass


#Tangible Action Functions
func CameraTransition():
	pass #maybe put this in battlesystem instead?


#Communication Functions
func ResetScore():
	cameraManager.faebleSeen = false
	cameraManager.overflowFrame = false
	cameraManager.cameraManager.centerDistance = 0
	cameraManager.propsHit = 0
	cameraManager.backdropsHit = 0
	cameraManager.zoomLevel
	cameraManager.CamZoom(-4.5, 1)


#State Machine


#placeholder order of operations:
#When player starts capturing, battle system should disable all its functions until done
#Drop down battlers, slide in status plates, move away witches, etc
#Pop up wild faeble, "Now's your chance!", enable BehaviorManager to start queueing paths
#Enable CameraManager, transition from battle cam to capture cam
#FIX TEMP, move CameraManager's input code over to CaptureSystem
#Allow Film Switching, maybe with key or mouse input
#On click, do camera checks, take screenshot with PictureManager (Might combine)
#CamManager returns all check results, CaptureSystem scoring function reads through, outputs RNG floor
#RNG Check, compare random number (between score floor and max for film)
#If pass, play full anim, if fail, RNG determine how many shakes
#Assign picture to photo texture inset, with each shake anim, unfade photo texture
