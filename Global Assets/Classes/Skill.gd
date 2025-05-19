extends Resource
class_name Skill

@export var name:String
@export var school:School
@export var manaType:int
@export var manaCost:int #1 to 10
@export var magical:bool #if true, use magic stat
@export var priority:int
@export var armor:int
@export var damageTier:int
@export var statusType:String
@export var statusTier:int
@export var buffStat:int
@export var buffStages:int

@export var skillDamage:int #If this is zero, check for special effects
@export var witchSkill:bool #If true, this skill is cast from a witch
@export var commandDifficulty:int #This is a measure of how difficult the minigame should scale
@export var commandTiming:int #This determines how fast or slow the action command minigame is

@export var movePreview:CompressedTexture2D
@export var moveDisplay:CompressedTexture2D
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

enum Mana{
	Primordial=1,
	Enchantment,
	Arcane,
	Wild
}

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
