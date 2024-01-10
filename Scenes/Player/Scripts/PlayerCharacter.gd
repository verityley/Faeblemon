extends TileEntity


var inputDir:Vector2i
var movingLeft:bool
var movingRight:bool
var movingUp:bool
var movingDown:bool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(_delta):
	
	movingLeft = Input.is_action_pressed("MoveLeft")
	movingRight = Input.is_action_pressed("MoveRight")
	movingUp = Input.is_action_pressed("MoveUp")
	movingDown = Input.is_action_pressed("MoveDown")
	
	if Input.is_action_pressed("Run"):
		moveTime = 0.2
	else:
		moveTime = 0.3
	
	if movingLeft and !movingRight:
		inputDir.x = -1
	elif movingRight and !movingLeft:
		inputDir.x = 1
	else:
		inputDir.x = 0
	
	if movingUp and !movingDown:
		inputDir.y = -1
	elif movingDown and !movingUp:
		inputDir.y = 1
	else:
		inputDir.y = 0
	
	if isMoving == false and inputDir != Vector2i(0,0):
			if self.CheckTarget(inputDir) == true:
				self.MoveByDirection(inputDir)
