extends TileEntity

@export var walkPath:Array[Vector3i]
var pathIndex:int = 0
@export var patrolMovement:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isPathing == false and patrolMovement == true:
		PathfindToPosition(walkPath[pathIndex])
		pathIndex += 1
		if pathIndex >= walkPath.size():
			pathIndex = 0
