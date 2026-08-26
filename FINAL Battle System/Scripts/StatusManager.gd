extends Node3D
class_name StatusManager

var bubbleContainers:Array
var bubbleFills:Array
var bubbleBacks:Array


func _ready():
	Initialize()


func Initialize():
	for bubble in get_children():
		bubbleContainers.append(bubble.get_child(0))
		bubbleFills.append(bubble.get_child(1))
		bubbleBacks.append(bubble.get_child(2))


func MaxBuildupReset(maxBuildup:int):
	#Determine how many containers vs pips are needed
	var containers:int = ceili(float(maxBuildup)/2)
	var extraContainers:int
	
	if containers > 10:
		extraContainers = ceili(float(maxBuildup - 20)/2)
		containers = 10
	
	for i in range(bubbleContainers.size()):
		bubbleContainers[i].frame = 0
		bubbleFills[i].frame = 0
		bubbleBacks[i].frame = 0
		bubbleContainers[i].hide()
		bubbleFills[i].hide()
		bubbleBacks[i].hide()
	
	var lastBubble
	var lastFill
	var lastBack
	for h in containers:
		var bubble:Sprite3D = bubbleContainers[h]
		var fill:Sprite3D = bubbleFills[h]
		var back:Sprite3D = bubbleBacks[h]
		bubbleContainers[h].show()
		bubbleFills[h].show()
		bubbleBacks[h].show()
		bubble.frame = 2
		fill.frame = 2
		back.frame = 2
		lastBubble = bubble
		lastFill = fill
		lastBack = back
	
	if extraContainers > 0:
		for e in range(extraContainers):
			bubbleContainers[e].show()
			bubbleFills[e].show()
			bubbleBacks[e].show()
			bubbleContainers[e].frame = 4
			bubbleFills[e].frame = 4
			bubbleBacks[e].frame = 4
			lastBubble = bubbleContainers[e]
			lastFill = bubbleFills[e]
			lastBack = bubbleBacks[e]
	
	if extraContainers <= 0:
		var leftover:int = containers*2 - maxBuildup
		if leftover != 0:
			lastBubble.frame = 2 - leftover
			lastFill.frame = 2 - leftover
			lastBack.frame = 2 - leftover
		prints("Containers:", containers, "Extras:", extraContainers, "Leftover Extra:", leftover)
	else:
		var leftover:int = ((containers*2) + (extraContainers*2)) - maxBuildup
		prints("Containers:", containers, "Extras:", extraContainers, "Leftover Extra:", leftover)
		if leftover != 0:
			lastBubble.frame = 4
			lastFill.frame = 4
			lastBack.frame = 4
	
	
	pass #Include handling for hitting 0, going over max, etc


func SetStatusDisplay(maxBuildup:int, curBuildup:int, type:Enums.Status):
	#Determine how many containers vs pips are needed
	var containers:int = ceili(float(curBuildup)/2)
	var maxContainers:int = ceili(float(maxBuildup)/2)
	var extraContainers:int
	var maxExtras:int
	#prints(containers, ceili(float(maxHealthPips)/4))
	
	if maxContainers > 10 and containers > 10:
		extraContainers = ceili(float(curBuildup - 20)/2)
		maxExtras = ceili(float(maxBuildup - 20)/2)
		#print(extraContainers)
		#print(maxExtras)
		containers = 10
		maxContainers = 10
	
	if containers <= 10 and maxContainers > 10:
		maxContainers = 10
	
	#prints("Total Health:", maxHP, "Current Health:", curHP)
	#print(maxContainers)
	var lastFill
	for i in maxContainers:
		bubbleFills[i].frame = 0
	
	for h in containers:
		bubbleFills[h].frame = 2
		lastFill = bubbleFills[h]
	
	#for j in maxExtras:
	#	healthFills[j].frame = 4
	
	if extraContainers > 0:
		for e in range(extraContainers):
			bubbleFills[e].frame = 4
			lastFill = bubbleFills[e]
	
	if extraContainers <= 0:
		var leftover:int = curBuildup % 2
		print("Leftover: ", leftover)
		if leftover != 0:
			lastFill.frame = leftover
	else:
		var leftover:int = curBuildup % 2
		print("Leftover Extra: ", leftover)
		if leftover != 0:
			lastFill.frame = 4 + leftover
	#print(leftover)
	for i in maxContainers:
		if type == Enums.Status.Clear:
			bubbleFills[i].hide()
		else:
			bubbleFills[i].show()
			bubbleFills[i].frame_coords.y = (type-1)
	pass #Include handling for hitting 0, going over max, etc
