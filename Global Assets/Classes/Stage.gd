extends Resource
class_name Stage

@export var stageName:String
@export var stageLayers:Array[Texture2D] = [
null,null,null,null,null,null,null,null,null,null,null,null,null]
@export var stageLighting:Dictionary = {
	"Energy" : 40.0,
	"Color" : Color(1,1,1,1)
}

#Prop set is texture + vertical offset, rather than item + chance, maybe replace with resource later?
@export var componentPool:Dictionary
@export var componentPositions:Array[Vector3]
@export var propSet:Dictionary[Texture2D, float]
@export var propPositions:Array[Vector3]
@export var spawnPool:Dictionary[Faeble, int]
#@export var NPCSchedule:Dictionary


func faebleGrabBag() -> Faeble:
	var spawn:Faeble
	var pool:Array
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	for faeble in spawnPool:
		for i in range(spawnPool[faeble]):
			pool.append(faeble.duplicate())
			print(faeble.name)
	var roll:int = RNG.randi_range(0, pool.size()-1)
	spawn = pool[roll]
	prints("Rolled",roll,"and found:",spawn.name,)
	return spawn
