extends Sprite2D
class_name StatusBox

@export var heartOffset:int = 25

var maxHealthPips:int
var currentHealthPips:int
var healthContainers:Array
var healthFills:Array
var maxEnergyPips:int
var currentEnergyPips:int
var maxStatusPips:int
var currentStatusPips:int
var maxMovePips:int
var currentMovePips:int
var currentSpeedNum:int
var faebleNameDisplay:String
var faebleLevelDisplay:String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func ResetStats(faebleEntry:Faeble):
	for sprite in healthContainers:
		sprite.queue_free()
	maxHealthPips = faebleEntry.maxHP
	maxEnergyPips = faebleEntry.maxEnergy
	maxMovePips = faebleEntry.grace/5+1 #Allow for speed stages eventually
	faebleNameDisplay = faebleEntry.name
	faebleLevelDisplay = str(faebleEntry.level)
	MaxHealthReset()
	SetHealthDisplay(faebleEntry.currentHP)
	ResetSpeed(faebleEntry.grace, maxMovePips)


func MaxHealthReset():
	#Determine how many containers vs pips are needed
	var containers:int = ceili(float(maxHealthPips)/4)
	var extraContainers:int
	#prints(containers, ceili(float(maxHealthPips)/4))
	
	if containers > 10:
		extraContainers = ceili(float(maxHealthPips - 40)/2)
		print(extraContainers)
		containers = 10
	
	var lastHeart
	var lastFill
	for h in containers:
		var newHeart = Sprite2D.new()
		var newFill = Sprite2D.new()
		healthContainers.append(newHeart)
		healthFills.append(newFill)
		newHeart.texture = $HeartContainer.texture
		newHeart.hframes = $HeartContainer.hframes
		newHeart.frame = 4
		newFill.texture = $HeartFill.texture
		newFill.hframes = $HeartFill.hframes
		newFill.frame = 4
		add_child(newFill)
		add_child(newHeart)
		if lastHeart != null:
			newHeart.position.x = lastHeart.position.x + heartOffset
			newHeart.position.y = lastHeart.position.y
			newFill.position = newHeart.position
		else:
			newHeart.position.x = $HeartContainer.position.x
			newHeart.position.y = $HeartContainer.position.y
			newFill.position = newHeart.position
		lastHeart = newHeart
		lastFill = newFill
	
	if extraContainers > 0:
		for e in range(extraContainers):
			healthContainers[e].frame = 6
			healthFills[e].frame = 6
			lastHeart = healthContainers[e]
			lastFill = healthFills[e]
	
	if extraContainers <= 0:
		var leftover:int = containers*4 - maxHealthPips
		if leftover != 0:
			lastHeart.frame = 4 - leftover
			lastFill.frame = 4 - leftover
	else:
		var leftover:int = ((containers*4) + (extraContainers*2)) - maxHealthPips
		prints("Containers:", containers, "Extras:", extraContainers, "Leftover Extra:", leftover)
		if leftover != 0:
			lastHeart.frame = 5
			lastFill.frame = 5
	#print(leftover)
	pass #Include handling for hitting 0, going over max, etc

func SetHealthDisplay(total:int):
	#Determine how many containers vs pips are needed
	var containers:int = ceili(float(total)/4)
	var maxContainers:int = ceili(float(maxHealthPips)/4)
	var extraContainers:int
	var maxExtras:int
	#prints(containers, ceili(float(maxHealthPips)/4))
	
	if maxContainers > 10 and containers > 10:
		extraContainers = ceili(float(total - 40)/2)
		maxExtras = ceili(float(maxHealthPips - 40)/2)
		#print(extraContainers)
		#print(maxExtras)
		containers = 10
		maxContainers = 10
	
	if containers <= 10 and maxContainers > 10:
		maxContainers = 10
	
	prints("Total Health:", maxHealthPips, "Current Health:", total)
	#print(maxContainers)
	var lastFill
	for i in maxContainers:
		healthFills[i].frame = 0
	
	for h in containers:
		healthFills[h].frame = 4
		lastFill = healthFills[h]
	
	#for j in maxExtras:
	#	healthFills[j].frame = 4
	
	if extraContainers > 0:
		for e in range(extraContainers):
			healthFills[e].frame = 6
			lastFill = healthFills[e]
	
	if extraContainers <= 0:
		var leftover:int = total % 4
		print("Leftover: ", leftover)
		if leftover != 0:
			lastFill.frame = leftover
	else:
		var leftover:int = total % 2
		print("Leftover Extra: ", leftover)
		if leftover != 0:
			lastFill.frame = 4 + leftover
	#print(leftover)
	pass #Include handling for hitting 0, going over max, etc

func ResetSpeed(grace:int, maxPoints:int):
	$SpeedDisplay.text = str(grace)
	$MoveContainer.frame = maxPoints
	$MoveFill.frame = maxPoints

func SetEnergyDisplay(amount:int):
	pass

func SetSpeedDisplay(total:int):
	$SpeedDisplay.text = str(total)

func SetMovepointsDisplay(total:int):
	$MoveFill.frame = total

func ChangeStatus(amount:int):
	pass #Include handling for hitting half, hitting full, reducing past thresholds, etc

func ChangeStage(amount:int):
	pass
