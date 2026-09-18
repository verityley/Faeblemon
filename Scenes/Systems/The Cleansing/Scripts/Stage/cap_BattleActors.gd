extends Node3D
class_name BattleActors

@export var actors:Dictionary[Actors,Node3D]
@export var anchorLayers:Dictionary[Actors,Node3D]
@export var anchorLocations:Dictionary[Actors,Vector3]
@export var healthOffset:float = -2.5

enum Actors {
	reset=-1,
	stage=0,
	pFaeble=1,
	pWitch,
	pUI,
	eFaeble,
	eWitch,
	eUI,
	camera,
	commands
}


func ActorSetup():
	actors[Actors.pFaeble].reparent(anchorLayers[Actors.pFaeble],false)
	actors[Actors.pFaeble].position = anchorLocations[Actors.pFaeble]
	actors[Actors.pFaeble].homeTarget = anchorLocations[Actors.pFaeble]
	actors[Actors.pFaeble].shiftTarget = anchorLocations[Actors.pFaeble] + Vector3(-5,-3,0)
	actors[Actors.pFaeble].rangeTargets[Enums.Ranges.Melee] = anchorLocations[Actors.pFaeble] + Vector3(0.5,0,0)
	actors[Actors.pFaeble].rangeTargets[Enums.Ranges.Near] = anchorLocations[Actors.pFaeble]
	actors[Actors.pFaeble].rangeTargets[Enums.Ranges.Far] = anchorLocations[Actors.pFaeble] + Vector3(-0.5,0,0)
	
	actors[Actors.pWitch].reparent(anchorLayers[Actors.pWitch],false)
	actors[Actors.pWitch].position = anchorLocations[Actors.pWitch]
	actors[Actors.pWitch].show()
	
	actors[Actors.pUI].reparent(anchorLayers[Actors.pUI],false)
	actors[Actors.pUI].position = anchorLocations[Actors.pUI]
	
	actors[Actors.eFaeble].reparent(anchorLayers[Actors.eFaeble],false)
	actors[Actors.eFaeble].position = anchorLocations[Actors.eFaeble]
	actors[Actors.eFaeble].homeTarget = anchorLocations[Actors.eFaeble]
	actors[Actors.eFaeble].shiftTarget = anchorLocations[Actors.eFaeble] + Vector3(5,-3,0)
	actors[Actors.eFaeble].rangeTargets[Enums.Ranges.Melee] = anchorLocations[Actors.eFaeble] + Vector3(-0.5,0,0)
	actors[Actors.eFaeble].rangeTargets[Enums.Ranges.Near] = anchorLocations[Actors.eFaeble]
	actors[Actors.eFaeble].rangeTargets[Enums.Ranges.Far] = anchorLocations[Actors.eFaeble] + Vector3(0.5,0,0)
	
	actors[Actors.eWitch].reparent(anchorLayers[Actors.eWitch],false)
	actors[Actors.eWitch].position = anchorLocations[Actors.eWitch]
	actors[Actors.eWitch].show()
	
	actors[Actors.eUI].reparent(anchorLayers[Actors.eUI],false)
	actors[Actors.eUI].position = anchorLocations[Actors.eUI]
	
	actors[Actors.camera].reparent(anchorLayers[Actors.camera],false)
	actors[Actors.camera].position = anchorLocations[Actors.camera]
	actors[Actors.camera].anchor = anchorLocations[Actors.camera]
	
