extends Node3D

enum Types{
	Empty = 0,
	PlayerFaeble,
	EnemyFaeble,
	FreeFaeble,
	Portrait,
	Prop,
	Component
	}

func CreateEntity(object, type:int):
	pass #Use object as key in a dictionary entry for future recall


func PlaceEntity(key, target:Vector3):
	pass


func MoveEntity(key, target:Vector3, speed:float):
	pass


func ClearEntity(key):
	pass
