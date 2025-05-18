extends Node3D
class_name HealthManager

var healthContainers:Array
var healthFills:Array


func _ready():
	Initialize()


func Initialize():
	for heart in get_children():
		healthContainers.append(heart.get_child(0))
		healthFills.append(heart.get_child(1))


func MaxHealthReset(maxHP:int):
	#Determine how many containers vs pips are needed
	var containers:int = ceili(float(maxHP)/4)
	var extraContainers:int
	
	if containers > 10:
		extraContainers = ceili(float(maxHP - 40)/2)
		containers = 10
	
	for i in range(healthContainers.size()):
		healthContainers[i].frame = 0
		healthFills[i].frame = 0
		healthContainers[i].hide()
		healthFills[i].hide()
	
	var lastHeart
	var lastFill
	for h in containers:
		var heart:Sprite3D = healthContainers[h]
		var fill:Sprite3D = healthFills[h]
		healthContainers[h].show()
		healthFills[h].show()
		heart.frame = 4
		fill.frame = 4
		lastHeart = heart
		lastFill = fill
	
	if extraContainers > 0:
		for e in range(extraContainers):
			healthContainers[e].show()
			healthFills[e].show()
			healthContainers[e].frame = 6
			healthFills[e].frame = 6
			lastHeart = healthContainers[e]
			lastFill = healthFills[e]
	
	if extraContainers <= 0:
		var leftover:int = containers*4 - maxHP
		if leftover != 0:
			lastHeart.frame = 4 - leftover
			lastFill.frame = 4 - leftover
		prints("Containers:", containers, "Extras:", extraContainers, "Leftover Extra:", leftover)
	else:
		var leftover:int = ((containers*4) + (extraContainers*2)) - maxHP
		prints("Containers:", containers, "Extras:", extraContainers, "Leftover Extra:", leftover)
		if leftover != 0:
			lastHeart.frame = 5
			lastFill.frame = 5
	
	
	pass #Include handling for hitting 0, going over max, etc


func SetHealthDisplay(maxHP:int, curHP:int):
	#Determine how many containers vs pips are needed
	var containers:int = ceili(float(curHP)/4)
	var maxContainers:int = ceili(float(maxHP)/4)
	var extraContainers:int
	var maxExtras:int
	#prints(containers, ceili(float(maxHealthPips)/4))
	
	if maxContainers > 10 and containers > 10:
		extraContainers = ceili(float(curHP - 40)/2)
		maxExtras = ceili(float(maxHP - 40)/2)
		#print(extraContainers)
		#print(maxExtras)
		containers = 10
		maxContainers = 10
	
	if containers <= 10 and maxContainers > 10:
		maxContainers = 10
	
	prints("Total Health:", maxHP, "Current Health:", curHP)
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
		var leftover:int = curHP % 4
		print("Leftover: ", leftover)
		if leftover != 0:
			lastFill.frame = leftover
	else:
		var leftover:int = curHP % 2
		print("Leftover Extra: ", leftover)
		if leftover != 0:
			lastFill.frame = 4 + leftover
	#print(leftover)
	pass #Include handling for hitting 0, going over max, etc
