extends Sprite3D
class_name StatusBox3D

@export var heartOffset:float = 0.25
@export var energyOffset:float = 0.25

var maxHealthPips:int
var currentHealthPips:int
var healthContainers:Array
var healthFills:Array
var maxEnergyPips:int
var currentEnergyPips:int
var energyContainers:Array
var energyFills:Array
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
	for sprite in energyContainers:
		sprite.queue_free()
	maxHealthPips = faebleEntry.maxHP
	maxEnergyPips = faebleEntry.maxEnergy
	maxMovePips = faebleEntry.grace/5+1 #Allow for speed stages eventually
	faebleNameDisplay = faebleEntry.name
	faebleLevelDisplay = str(faebleEntry.level)
	MaxHealthReset()
	SetHealthDisplay(faebleEntry.currentHP)
	MaxEnergyReset()
	SetEnergyDisplay(faebleEntry.currentEnergy)
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
		var newHeart = Sprite3D.new()
		var newFill = Sprite3D.new()
		healthContainers.append(newHeart)
		healthFills.append(newFill)
		newHeart.texture = $HeartContainer.texture
		newHeart.hframes = $HeartContainer.hframes
		newHeart.frame = 4
		newHeart.render_priority = 2
		newFill.texture = $HeartFill.texture
		newFill.hframes = $HeartFill.hframes
		newFill.frame = 4
		newFill.render_priority = 1
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

func MaxEnergyReset():
	#Determine how many containers vs pips are needed
	var containers:int = ceili(float(maxEnergyPips)/2)
	var extraContainers:int
	prints(containers, ceili(float(maxHealthPips)/2))
	
	if containers > 10:
		extraContainers = ceili(float(maxEnergyPips - 20)/2)
		print(extraContainers)
		containers = 10
	
	var lastEnergy
	var lastFill
	for h in containers:
		var newEnergy = Sprite3D.new()
		var newFill = Sprite3D.new()
		energyContainers.append(newEnergy)
		energyFills.append(newFill)
		newEnergy.texture = $EnergyContainer.texture
		newEnergy.hframes = $EnergyContainer.hframes
		newEnergy.frame = 2
		newEnergy.render_priority = 2
		newFill.texture = $EnergyFill.texture
		newFill.hframes = $EnergyFill.hframes
		newFill.frame = 2
		newFill.render_priority = 1
		add_child(newFill)
		add_child(newEnergy)
		if lastEnergy != null:
			newEnergy.position.x = lastEnergy.position.x + energyOffset
			newEnergy.position.y = lastEnergy.position.y
			newFill.position = newEnergy.position
		else:
			newEnergy.position.x = $EnergyContainer.position.x
			newEnergy.position.y = $EnergyContainer.position.y
			newFill.position = newEnergy.position
		lastEnergy = newEnergy
		lastFill = newFill
	
	if extraContainers > 0:
		for e in range(extraContainers):
			energyContainers[e].frame = 4
			energyFills[e].frame = 4
			lastEnergy = energyContainers[e]
			lastFill = energyFills[e]
	
	if extraContainers <= 0:
		var leftover:int = containers*2 - maxEnergyPips
		if leftover != 0:
			lastEnergy.frame = 2 - leftover
			lastFill.frame = 2 - leftover
	else:
		var leftover:int = ((containers*2) + (extraContainers*2)) - maxEnergyPips
		prints("Energy Containers:", containers, "Extras:", extraContainers, "Leftover Extra:", leftover)
		if leftover != 0:
			lastEnergy.frame = 3
			lastFill.frame = 3
	#print(leftover)
	pass #Include handling for hitting 0, going over max, etc

func SetEnergyDisplay(total:int):
	#Determine how many containers vs pips are needed
	var containers:int = ceili(float(total)/2)
	var maxContainers:int = ceili(float(maxEnergyPips)/2)
	var extraContainers:int
	var maxExtras:int
	#prints(containers, ceili(float(maxEnergyPips)/4))
	
	if maxContainers > 10 and containers > 10:
		extraContainers = ceili(float(total - 20)/2)
		maxExtras = ceili(float(maxEnergyPips - 20)/2)
		#print(extraContainers)
		#print(maxExtras)
		containers = 10
		maxContainers = 10
	
	if containers <= 10 and maxContainers > 10:
		maxContainers = 10
	
	prints("Total Energy:", maxEnergyPips, "Current Energy:", total)
	#print(maxContainers)
	var lastFill
	for i in maxContainers:
		energyFills[i].frame = 0
	
	for h in containers:
		energyFills[h].frame = 2
		lastFill = energyFills[h]
	
	#for j in maxExtras:
	#	healthFills[j].frame = 4
	
	if extraContainers > 0:
		for e in range(extraContainers):
			energyFills[e].frame = 4
			lastFill = energyFills[e]
	
	if extraContainers <= 0:
		var leftover:int = total % 2
		print("Leftover: ", leftover)
		if leftover != 0:
			lastFill.frame = leftover
	else:
		var leftover:int = total % 2
		print("Leftover Extra: ", leftover)
		if leftover != 0:
			lastFill.frame = 2 + leftover
	#print(leftover)
	pass #Include handling for hitting 0, going over max, etc

func SetSpeedDisplay(total:int):
	$SpeedDisplay.text = str(total)

func SetMovepointsDisplay(total:int):
	$MoveFill.frame = total

func ChangeStatus(amount:int):
	pass #Include handling for hitting half, hitting full, reducing past thresholds, etc

func ChangeStage(amount:int):
	pass
