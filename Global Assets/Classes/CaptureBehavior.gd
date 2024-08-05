extends Resource
class_name Behavior

@export var name:String

@export_category("Capture Parameters")
@export var paths:Array[CapturePath]
@export_range(0, 100) var poseChance:int = 100
#Can also use these behaviors for AI action choice during battles, eventually

func PatienceCheck():
	pass
