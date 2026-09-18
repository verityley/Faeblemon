extends Node
class_name Rule

@export var layer:int #What priority layer the rule operates at, beat out by superceding rules of higher layer
@export_multiline() var rulesText:String

@export var blacklist:bool #flips affected lists to exclusion lists
@export var affectedDomains:Array[Domain]
@export var affectedSchools:Array[School]
@export var affectedRaw:Array[int]

@export var onesided:bool = false
@export var higherDif:int = -1
@export var lowerDif:int = -1


signal wincon(p1Pass:bool, p2Pass:bool, equal:bool)
signal ncResults(amount:int)
signal tiebreaker
signal modifier(p1Side:bool, p2Side:bool, amount:int)
signal field(invert:bool)


func Conditional() -> bool:
	return true

func Outcome():
	pass
