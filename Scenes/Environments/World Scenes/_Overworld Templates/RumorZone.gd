extends Area3D
var currentNPCs:Array[NPC]
var currentTracks:Array[NPC]
@export var rumorSystem:RumorSystem
@export var zoneType:Enums.ZoneTypes

func NPCTally(body:Area3D=null, enter:bool=true):
	var enterChar:Node3D = body.get_parent_node_3d().get_parent_node_3d()
	if enterChar is not NPC:
		return
	if rumorSystem.allTelltales.has(enterChar):
		if enter:
			print("Adding NPC to Zone")
			currentNPCs.append(enterChar)
		else:
			currentNPCs.erase(enterChar)
	elif rumorSystem.allTracks.has(enterChar):
		if enter:
			print("Adding NPC to Zone")
			currentTracks.append(enterChar)
		else:
			currentTracks.erase(enterChar)
	else:
		print("Not a Telltale, skipping!")
