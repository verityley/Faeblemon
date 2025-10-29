extends Node3D
class_name OverworldManager

@export var currentScene:Node3D
@export var playerLocation:Vector3

@export var player:Node3D
@export var camera:Camera3D
@export var navmesh:NavigationRegion3D
@export var sceneFX:Node3D
@export var investigation:Node3D
@export var rumorSystem:RumorSystem

var allNPCs:Array[NPC]

func LoadOverworld(oScene:OverworldManager, destination:Vector3):
	pass

func CreateNPC(NPCType:NPC, location=null):
	if location == null:
		location = NavigationServer3D.region_get_random_point(navmesh,0,true)

func LoadInvestigation(stage:Stage):
	player.lockdown = true
	for npc in allNPCs:
		npc.lockdown = true
		npc.hide()
	navmesh.enabled = false
	player.hide()
	navmesh.hide()
	sceneFX.hide()
	var iScene = load("res://Scenes/Environments/Investigation Scenes/LayerManager.tscn").instantiate()
	investigation.add_child(iScene)
	iScene.stageCamera.make_current()
	iScene.layerSpeed = 0.01
	iScene.LayerSpacing(0, 0)
	iScene.layerSpeed = 0.2
	iScene.LoadScene(stage, iScene.Transitions.None)

func NewBattle(team:Array[Faeble], stage:Stage):
	player.lockdown = true
	for npc in allNPCs:
		npc.lockdown = true
		npc.hide()
	navmesh.enabled = false
	player.hide()
	navmesh.hide()
	sceneFX.hide()
	var iScene = load("res://Scenes/Environments/Investigation Scenes/LayerManager.tscn").instantiate()
	investigation.add_child(iScene)
	iScene.stageCamera.make_current()
	iScene.layerSpeed = 0.01
	iScene.LayerSpacing(0, 0)
	iScene.layerSpeed = 0.2
	iScene.LoadScene(stage, iScene.Transitions.None)

func NewInterview(conversation:Message, speaker:Speaker, stage:Stage):
	player.lockdown = true
	for npc in allNPCs:
		npc.lockdown = true
		npc.hide()
	navmesh.enabled = false
	player.hide()
	navmesh.hide()
	sceneFX.hide()
	var iScene = load("res://Scenes/Environments/Investigation Scenes/LayerManager.tscn").instantiate()
	investigation.add_child(iScene)
	iScene.stageCamera.make_current()
	iScene.layerSpeed = 0.01
	iScene.LayerSpacing(0, 0)
	iScene.layerSpeed = 0.2
	iScene.LoadScene(stage, iScene.Transitions.None)

func UnloadInvestigation():
	for child in investigation.get_children():
		child.queue_free()
	camera.make_current()
	player.lockdown = false
	for npc in allNPCs:
		npc.lockdown = false
		npc.show()
	navmesh.enabled = true
	player.show()
	navmesh.show()
	sceneFX.show()

func SceneTransition():
	
	pass #Snapshot, picture frame swipe, fade to black, camera move

func SceneSetup():
	pass #Determine NPC schedules, establish thresholds, sightings, barriers, rumors, etc
