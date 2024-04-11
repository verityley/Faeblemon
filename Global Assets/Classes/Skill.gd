extends Resource
class_name Skill

@export var skillName:String
@export var skillType:School
@export var skillCost:int #1 to 10
@export var skillNature:String #Physical, Magical, etc. Determines stat used.
@export var skillDamage:int #If this is zero, check for special effects
@export var commandDifficulty:int #This is a measure of how difficult the minigame should scale
@export var commandTiming:int #This determines how fast or slow the action command minigame is

@export_multiline var moveDescription:String
#@export var skillAnim:AnimatedSprite2D

@export_category("Battlefield Traits")
@export var targetType:String #Ally, Enemy, All, etc
@export var targetScope:String #Single, AoE, etc
@export var rangeMin:int = 0
@export var rangeMax:int = 10
@export var canPierce:bool = true
@export var canArc:bool = true
@export var canBurst:bool = false
@export var burstRange:int = 0
@export var targetAlly:bool = false
@export var targetAll:bool = false

func Target(battleManager:BattleManager, user:Battler):
	battleManager.ChangeBoardState("Attacking")
	battleManager.CheckAttackRange(user, self)

func Execute(battleManager:BattleManager, user:Battler, target:Battler):
	print("Error! Attack has no function. If basic damaging attack, insert ref to DamageCalc")
	var damageTally:int
	if skillDamage > 0:
		damageTally = battleManager.DamageCalc(user, target, self)
	damageTally = -clampi(damageTally, 0, 99)
	target.ChangeHealth(damageTally)
