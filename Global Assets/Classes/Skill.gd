extends Resource
class_name Skill

@export var name:String
@export var school:School
@export var magical:bool #if true, use magic stat
@export var priority:int
@export var pGuarding:bool
@export var mGuarding:bool
@export var rangeBands:Array[bool] = [false,false,false]
@export var damageTier:int
@export var statusType:Enums.Status
@export var statusTier:int
@export var buffStat:Enums.BuffableAttrs
@export var buffStages:int
@export var movement:int = 0
@export var aura:int
@export var witchSkill:bool #If true, this skill is cast from a witch

@export var movePreview:CompressedTexture2D
@export var moveDisplay:CompressedTexture2D
@export_multiline var moveDescription:String
#@export var skillAnim:AnimatedSprite2D


func BeforeSkill(system:BattleSystemFINAL, user:BattlerData, target:BattlerData) -> bool:
	var conditional:bool = true
	return conditional

func ExecuteSkill(system:BattleSystemFINAL, user:BattlerData, target:BattlerData):
	pass

func AfterSkill(system:BattleSystemFINAL, user:BattlerData, target:BattlerData):
	if buffStages > 0:
		user.buffStages[buffStat] = clampi(user.buffStages[buffStat]+buffStages,-BattleCalcs.maxStages,BattleCalcs.maxStages)


func Execute(battleSystem:BattleSystem, user:StageBattler, target:StageBattler):
	print("Error! Attack has no function. If basic damaging attack, insert ref to DamageCalc")
	#user.ChangeEnergy(-cost)
	var damageTally:int
	#if mimic school, user sig school used as move school
	#if skillDamage > 0:
	damageTally = battleSystem.DamageCalc(self, user, target)
	var superFX:bool
	var weakFX:bool
	var matchupMod:int = battleSystem.CheckMatchups(target.faebleInstance, school)
	if matchupMod > 0:
		superFX = true
		weakFX = false
	elif matchupMod < 0:
		superFX = false
		weakFX = true
	else:
		superFX = false
		weakFX = false
	#battleSystem.DamagePopup(target.positionIndex, -damageTally, superFX, weakFX)
	target.ChangeHealth(damageTally)
