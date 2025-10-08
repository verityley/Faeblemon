extends Node3D
class_name Threshold
@export var rumorSystem:RumorSystem
@export var faeblePresent:Faeble
@export var barrierPresent:Node3D
@export var targetScene:Stage
@export var rumorZones:Dictionary[Enums.ZoneTypes,Area3D] #for tracking npcs within different area types
@export var landmarks:Array[Message] #list of landmark-tied messages for objects in the area
@export var comments:Array[Message] #dynamic list of messages, added to by circumstance

func AssignRumors():
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	var targetNPCs:Array[NPC]
	var target:NPC
	var breakcount:int = 0
	var unassigned:bool = true
	#Find Near Telltale
	if rumorZones[Enums.ZoneTypes.Near] != null:
		targetNPCs = rumorZones[Enums.ZoneTypes.Near].currentNPCs.duplicate()
		print(targetNPCs)
		while unassigned:
			print("Breakcount: ", breakcount)
			if breakcount >= 10:
				print("Too many attempts, break loop!")
				break
			breakcount += 1
			target = targetNPCs[RNG.randi_range(0,targetNPCs.size()-1)]
			if target == null:
				break
			if target.rumor == null:
				unassigned = false
				print("Assigning rumor to ", target)
				target.rumor = rumorSystem.zoneMessages[Enums.ZoneTypes.Near]
				break
	#Find Far Telltale, exclude any Near NPCs
	unassigned = true
	breakcount = 0
	targetNPCs.clear()
	if rumorZones[Enums.ZoneTypes.Far] != null:
		targetNPCs = rumorZones[Enums.ZoneTypes.Far].currentNPCs.duplicate()
		while unassigned:
			print("Breakcount: ", breakcount)
			if breakcount >= 10:
				print("Too many attempts, break loop!")
				break
			breakcount += 1
			print("Pre-Near-Clear", targetNPCs)
			for t in rumorZones[Enums.ZoneTypes.Near].currentNPCs:
				if targetNPCs.has(t):
					targetNPCs.erase(t)
			print("Post-Near-Clear", targetNPCs)
			target = targetNPCs[RNG.randi_range(0,targetNPCs.size()-1)]
			if rumorZones[Enums.ZoneTypes.Near].currentNPCs.has(target):
				pass
			if target != null:
				print("Assigning rumor to ", target)
				target.rumor = rumorSystem.zoneMessages[Enums.ZoneTypes.Far]
				break
	#Find Upstreet/Downstreet/Onstreet Telltale
	unassigned = true
	breakcount = 0
	targetNPCs.clear()
	if rumorZones[Enums.ZoneTypes.Onstreet] != null:
		targetNPCs = rumorZones[Enums.ZoneTypes.Onstreet].currentNPCs
		while unassigned:
			if breakcount >= 10:
				break
			breakcount += 1
			target = targetNPCs[RNG.randi_range(0,targetNPCs.size()-1)]
			if target == null:
				break
			if target.rumor == null:
				unassigned = false
				print("Assigning rumor to ", target)
				target.rumor = rumorSystem.zoneMessages[Enums.ZoneTypes.Onstreet]
				break
	#Find Uphill/Downhill Telltale
	#From random Telltales in Far range, assign Landmark messages
	targetNPCs.clear()
	targetNPCs = rumorZones[Enums.ZoneTypes.Far].currentNPCs
	for i in landmarks:
		unassigned = true
		breakcount = 0
		while unassigned:
			if breakcount >= 10:
				break
			breakcount += 1
			target = targetNPCs[RNG.randi_range(0,targetNPCs.size()-1)]
			if target == null:
				break
			if target.rumor == null:
				unassigned = false
				target.rumor = landmarks[i]
				break
	#Assign Comment messages to random Telltales in range
	targetNPCs.clear()
	targetNPCs = rumorZones[Enums.ZoneTypes.Far].currentNPCs
	for i in landmarks:
		unassigned = true
		breakcount = 0
		while unassigned:
			if breakcount >= 10:
				break
			breakcount += 1
			target = targetNPCs[RNG.randi_range(0,targetNPCs.size()-1)]
			if target == null:
				break
			if target.rumor == null:
				unassigned = false
				target.rumor = comments[i]
				break
	#Spawn Tracks within Far range, assign hint messages from faeble entry descriptions
	pass

#when checking telltales, ensure they arent already used for another rumor
#only telltales that should need exclusive checks are near/far, check near then remove from viable far
#only use near/far for assigning Tracks, check if in tracks or telltales array on parent
#rumorzone array is "currentNPCs"
