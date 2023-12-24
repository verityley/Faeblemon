extends TileEntity

@export var walkPath:Array[Vector2i]
var pathIndex:int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if isMoving == false:
		var walkDir:Vector2i = walkPath[pathIndex]
		
		if walkDir != null:
			if self.CheckTarget(walkDir) == true:
				self.MoveByDirection(walkDir)
				pathIndex += 1
				if pathIndex >= walkPath.size():
					pathIndex = 0
