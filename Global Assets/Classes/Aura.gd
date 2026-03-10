extends Resource
class_name Aura

@export var name:String
@export var linkedDomain:Domain
@export var linkedSchool:School
@export var doubleLinked:bool = false
@export var onlyLinked:bool = false
@export var excludeLinked:bool = false
@export var checkMove:bool = false

@export var activeStep:Enums.BattleSteps

@export var hpTick:int = 0
@export var buildupTick:int = 0
@export var status:Enums.Status
@export var matchStatus:bool = false
@export var damageMod:float = 0.0 #Set to at least 1 even if using tiered
@export var buildupMod:float = 0.0 #Set to at least 1 even if using tiered
@export var tiered:bool = false
@export var tieredMod:Array[float] #Use three if damage, two if status
@export var priorityMod:int = 0
@export var priorityFlip:bool = false
@export var rangeMod:Array[bool] = [false,false,false]
@export var pGuarding:bool = false
@export var mGuarding:bool = false

@export var additive:bool = false #will add range/damage/etc on top, add to true
@export var multiplicative:bool = false #will multiply damage/etc, no effect on range or bools
@export var subtractive:bool = false #will take away range/damage/etc, subtract to false
@export var replacement:bool = false #will set range/damage/etc to value, bools replace

func LinkCheck(faeble:BattlerData, default:bool=true) -> bool:
	if linkedSchool != null and checkMove == false:
		if onlyLinked and faeble.instance.affinity == linkedSchool:
			print("User matches Link, Pass")
			return true
		elif onlyLinked and faeble.instance.affinity != linkedSchool:
			print("User lacks Link, Fail")
			return false
		
		if excludeLinked and faeble.instance.affinity == linkedSchool:
			print("User matches Exclusion, Fail")
			return false
		elif excludeLinked and faeble.instance.affinity != linkedSchool:
			print("User lacks Exclusion, Pass")
			return true
		print("Defaulting to ",default)
		return default
	
	if linkedSchool != null and checkMove == true:
		if onlyLinked and faeble.currentSpell.school == linkedSchool:
			print("User's Move matches Link, Pass")
			return true
		elif onlyLinked and faeble.currentSpell.school != linkedSchool:
			print("User's Move lacks Link, Fail")
			return false
		
		if excludeLinked and faeble.currentSpell.school == linkedSchool:
			print("User's Move matches Exclusion, Fail")
			return false
		elif excludeLinked and faeble.currentSpell.school != linkedSchool:
			print("User's Move lacks Exclusion, Pass")
			return true
		print("Defaulting to ",default)
		return default
	
	if linkedDomain != null:
		if onlyLinked:
			if faeble.instance.firstDomain == linkedDomain or faeble.instance.secondDomain == linkedDomain:
				print("User matches Link, Pass")
				return true
			else:
				print("User lacks Link, Fail")
				return false
		
		if excludeLinked:
			if faeble.instance.firstDomain == linkedDomain or faeble.instance.secondDomain == linkedDomain:
				print("User matches Exclusion, Fail")
				return false
			else:
				print("User lacks Exclusion, Pass")
				return true
		print("Defaulting to ",default)
		return default
	return default

func AtBattleStep(step:int, battle:BattleSystemFINAL):
	if step == activeStep:
		pass
