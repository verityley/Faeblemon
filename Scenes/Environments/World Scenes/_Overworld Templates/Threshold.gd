extends Node3D
class_name Threshold
#@export var rumorSystem:RumorSystem
@export var faeblePresent:Faeble
@export var barrierPresent:Node3D
@export var targetScene:Stage
@export var breakCount:int = 10
@export var rumorZones:Dictionary[Enums.ZoneTypes,Area3D] #for tracking npcs within different area types
@export var landmarks:Array[Message] #list of landmark-tied messages for objects in the area
var usedLandmarks:Array[Message]
var usedNPCs:Array[NPC]
var usedTracks:Array[NPC]

func AssignRumor(area:int, rumor:Message=null, tracks:bool=false, excludeArea:int=0):
	var targets:Array[NPC] = rumorZones[area].currentNPCs.duplicate()
	if rumorZones[area] == null:
		print("No area trigger exists on this Threshold.")
		return
	if rumor == null:
		var tempMarks = landmarks.duplicate()
		tempMarks.shuffle()
		for landmark in tempMarks:
			if usedLandmarks.has(landmark) == false:
				rumor = landmark
				usedLandmarks.append(landmark)
				break
		if rumor == null:
			print("Unable to find unused landmark message.")
			return
	if tracks:
		targets = rumorZones[area].currentTracks.duplicate()
	targets.shuffle()
	if excludeArea != 0:
		if tracks:
			for t in rumorZones[excludeArea].currentTracks:
				if targets.has(t):
					targets.erase(t)
		else:
			for t in rumorZones[excludeArea].currentNPCs:
				if targets.has(t):
					targets.erase(t)
		if targets.size() < 1:
			print("No remaining targets outside excluded area.")
			return
	for i in range(breakCount):
		var target:NPC = targets.pop_front()
		if target == null:
			print("No remaining targets without rumors.")
			break
		if target.rumor == null:
			target.rumor = rumor
			print("Assigning rumor to target: ", rumor.messageText)
			if tracks:
				usedTracks.append(target)
			else:
				usedNPCs.append(target)
			break

func RumorCleanup():
	#Reset used landmarks list, and remove rumors from usedNPCS, optionally delete usedTracks
	pass

#
#func AssignRumors():
	#var RNG = RandomNumberGenerator.new()
	#RNG.randomize()
	#var targetNPCs:Array[NPC]
	#var breakcount:int = 0
	##Find Near Tracks
	#if rumorZones[Enums.ZoneTypes.Near] != null:
		#targetNPCs = rumorZones[Enums.ZoneTypes.Near].currentTracks.duplicate()
		#targetNPCs.shuffle()
		#for target in targetNPCs:
			#if breakcount >= nearCount:
				#break
			#if target.rumor == null:
				#print("Assigning rumor to ", target)
				#target.rumor = trackPrefaces[Enums.ZoneTypes.Near]
				#if faeblePresent != null:
					#var desc:String = faeblePresent.trackDescriptions[RNG.randi_range(0,faeblePresent.trackDescriptions.size()-1)]
					#target.rumor.messageText += (" " + desc)
					#print(target.rumor.messageText)
				#breakcount += 1
	##Find Mid Tracks, exclude any Near NPCs
	#breakcount = 0
	#targetNPCs.clear()
	#if rumorZones[Enums.ZoneTypes.Mid] != null:
		#targetNPCs = rumorZones[Enums.ZoneTypes.Mid].currentTracks.duplicate()
		#targetNPCs.shuffle()
		#for t in rumorZones[Enums.ZoneTypes.Near].currentTracks:
			#if targetNPCs.has(t):
				#targetNPCs.erase(t)
		#if targetNPCs.size() > 0:
			#for target in targetNPCs:
				#if breakcount >= midCount:
					#break
				#if target.rumor == null:
					#print("Assigning rumor to ", target)
					#target.rumor = trackPrefaces[Enums.ZoneTypes.Mid]
					#if faeblePresent != null:
						#var desc:String = faeblePresent.trackDescriptions[RNG.randi_range(0,faeblePresent.trackDescriptions.size()-1)]
						#target.rumor.messageText += (" " + desc)
						#print(target.rumor.messageText)
					#breakcount += 1
	##Find Far Tracks, exclude any Mid NPCs
	#breakcount = 0
	#targetNPCs.clear()
	#if rumorZones[Enums.ZoneTypes.Far] != null:
		#targetNPCs = rumorZones[Enums.ZoneTypes.Far].currentTracks.duplicate()
		#targetNPCs.shuffle()
		#for t in rumorZones[Enums.ZoneTypes.Mid].currentTracks:
			#if targetNPCs.has(t):
				#targetNPCs.erase(t)
		#if targetNPCs.size() > 0:
			#for target in targetNPCs:
				#if breakcount >= farCount:
					#break
				#if target.rumor == null:
					#print("Assigning rumor to ", target)
					#target.rumor = trackPrefaces[Enums.ZoneTypes.Far]
					#if faeblePresent != null:
						#var desc:String = faeblePresent.trackDescriptions[RNG.randi_range(0,faeblePresent.trackDescriptions.size()-1)]
						#target.rumor.messageText += (" " + desc)
						#print(target.rumor.messageText)
					#breakcount += 1
	##Find Upstreet/Downstreet/Onstreet Telltale
	##Find Uphill/Downhill Telltale
	##From random Telltales in Far range, assign Landmark messages
	#targetNPCs.clear()
	#breakcount = 0
	#if rumorZones[Enums.ZoneTypes.Far] != null and landmarks.size() > 0:
		#targetNPCs = rumorZones[Enums.ZoneTypes.Far].currentNPCs.duplicate()
		#var targetLandmarks:Array[Message] = landmarks.duplicate()
		#targetNPCs.shuffle()
		#targetLandmarks.shuffle()
		#for target in targetNPCs:
			#if breakcount >= markCount:
				#break
			#if targetLandmarks.size() == 0:
				#break
			#if target.rumor == null:
				#print("Assigning rumor to ", target)
				#target.rumor = targetLandmarks.pop_front()
				#breakcount += 1
	##Assign Comment messages to random Telltales in range
	#targetNPCs.clear()
	#breakcount = 0
	#if rumorZones[Enums.ZoneTypes.Far] != null and comments.size() > 0:
		#targetNPCs = rumorZones[Enums.ZoneTypes.Far].currentNPCs.duplicate()
		#var targetComments:Array[Message] = comments.duplicate()
		#targetNPCs.shuffle()
		#targetComments.shuffle()
		#for target in targetNPCs:
			#if breakcount >= markCount:
				#break
			#if targetComments.size() == 0:
				#break
			#if target.rumor == null:
				#print("Assigning rumor to ", target)
				#target.rumor = targetComments.pop_front()
				#breakcount += 1
	##Spawn Tracks within Far range, assign hint messages from faeble entry descriptions
	#pass

#when checking telltales, ensure they arent already used for another rumor
#only telltales that should need exclusive checks are near/far, check near then remove from viable far
#only use near/far for assigning Tracks, check if in tracks or telltales array on parent
#rumorzone array is "currentNPCs"
